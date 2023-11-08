//
//  T9Strategy.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/16/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import LoginputEngineLib

extension T9Strategy {}

final class T9Strategy: InputDelegate {
    weak var pinYinSelector: PinYinSelector?

    var pinyin:[[String]] = []
    
    var pinyin2: [[String]] = []
    var pinyins:Pinyins?

    var bufferCache = ""
    override func getResult(WithBuffer buffer: String, quick: Bool, result: inout CodeTableArray) {
        if bufferCache != buffer {
            pinyins = Pinyins(n:buffer)
            if configManager.quanPin {
                
                pinyin = NumString.nums2pylist(n: buffer)
                pinyin2 = NumString.nums2pylist(n: buffer, reverse: true)
//                pinyins = NumString.nums2pylist(n: buffer)
//                if buffer == "6243" {
//                    pinyin[0].insert("na", at: 0)
//                    pinyin[1].insert("ge", at: 0)
//                }
//                if buffer == "4242" {
//                    pinyin[0].insert("ha", at: 0)
//                    pinyin[1].insert("ha", at: 0)
//                }
//                if buffer == "7487832" {
//                    pinyin[0].insert("shu", at: 0)
//                    pinyin[1].insert("ru", at: 0)
//                    pinyin[2].insert("fa", at: 0)
//                }
            }

            pinYinSelector?.update(pinyin: pinyin, p2: pinyin2, pinyins: pinyins!)
            bufferCache = buffer
        }

        t9GetResult(WithPinyin: pinyin, quick: quick, result: &result, pinyins:pinyins!)
    }

    func t9GetResult(WithPinyin pinyin: [[String]], quick: Bool, result: inout CodeTableArray, pinyins:Pinyins) {
//        let length = pinyin.count //多少个音节
        let length = pinyins.getSyllablesCount(index: 0) //多少个音节，这里取第一个拼音的音节数目
        let group = DispatchGroup()

        
        // 从这里改，拼音从这个地方开始改， 让每个拼音单独地get result，最后得到一个结果，把所有的结果append 上去，
        
        for (i,pinyinStruct) in pinyins.pinyins.enumerated() {
//            queue.async (group: group){
                let t = self.subResult(pinyin: pinyinStruct)
                if !t.isEmpty{
                    self.resultCache[i] = t
                }
//            }
        }
        if length < 2 {
            self.resultCache[0] = self.getSubResult(SubBuffer: self.pinyin, pathNumber: 30, subBuffer: pinyins)
        }
        
        // 现在把其他给结果的过程都删除了，给的结果就是整句结果和第一个字的结果
        
//        for index in 0 ..< 4 {
//            // 这里的作用好像是要判断一下音节有几个，如果音节长度在4以内，并且音节长度大于index,对音节进行切分来得到候选词
//            //如果切分的音节数目等于音节的长度，要进行整句搜索，则把num改成5，单个字或者词就30
//            //resultCache中存储查询得到的结果
//            guard length > index else { continue } //不满足 index 在length的范围这一条件后continue？
//            queue.async(group: group) {
//                let isFullLength = length == index + 1 // 当前音节的长度如果是等于所有音节的，那么是需要整句搜索的
//                let num = isFullLength ? 30 : 5 // 如果是在整句输入中的词汇候选，就少一点。  //如果是单字，把全长改大一点来兼容模糊音
//                let t = self.getSubResult(SubBuffer: Array(self.pinyin.prefix(index + 1)), pathNumber: num, subBuffer: pinyins)
//                self.resultCache[index + 1] = t
//            }
//        }
        let count = pinyins.pinyins.count //通过这个来判断self.resultCache中的数量
        if length > 4 { //音节数目 长度大于4
            queue.async(group: group) {// 同步
                let t = self.getSubResult(SubBuffer: self.pinyin, pathNumber: 2, subBuffer: pinyins)
                self.resultCache[count] = t
            }
        }
//        queue.async (group: group){
//            let t = self.fullSpellResult(pinyins: pinyins)
//            self.resultCache[11] = t
//        }
        
        if !quick || isVoiceOverOn {
            queue.async(group: group) {
                guard let first = self.pinyin.first else { return }
                let py = PyString.py2fuzzy(pyList: [first], config: self.configManager)
                guard py.count == 1 else { return }
                var tmpArr: [[CodeTable]] = []
                for s in py[0] {
                    guard let s1 = self.py2hz[s] else { continue } //s1 String    "累类雷泪蕾垒磊肋擂儡嘞镭勒耒羸涙嫘诔塁罍酹颣檑絫礌缧櫑礧洡頪畾蕌纝鑸"
                    let result = s1.map { CodeTable(Code: s, Table: String($0)) }
                    tmpArr.append(result)
                }
                let r = self.mashUp(contents: tmpArr)
                if let a = self.resultCache[0] {
                    self.resultCache[0] = a + r
                } else {
                    self.resultCache[0] = r
                }
            }
        }
        var customCodeTable: CodeTableArray = [] // 留给dag去重
        queue.async(group: group) {
            guard self.configManager.customCodeTableVersion >= 0 else { return }

            customCodeTable = self.dictDB.getCustomCodeTableOrderedByWeight(fromCode: self.inputBuffer)
        }
        _ = group.wait(timeout: DispatchTime.now() + 0.8)

        var filter = Set(customCodeTable + result)
        for i in (0 ... count).reversed() { //按照长度插入到结果中
            guard let cts = resultCache[i] else { continue }
            result += cts.filter { filter.insert($0).inserted }
        }

        for ct in customCodeTable {
            let num = Int(ct.weight)
            if result.count > num {
                result.insert(ct, at: num)
            } else {
                result.append(ct)
            }
        }
        //        if [4,6].contains(buffer.characters.count) {
        //            candidateCache = result
        //        }
        if result.isEmpty { result = candidateCache }
        else { candidateCache = result }
    }
    
    
    func subResult(pinyin:Pinyins.Pinyin) -> CodeTableArray{
        var result:CodeTableArray = []
        let length = pinyin.syllablesList.count //  音节数目

        
        
        for index in 0 ..< 5 {
            // 这里的作用好像是要判断一下音节有几个，如果音节长度在4以内，并且音节长度大于index,对音节进行切分来得到候选词
        
            guard length > index else { continue } //不满足 index 在length的范围这一条件后continue？
            let syllables:Array<String> = Array(pinyin.syllablesList[0...index])//截取部分拼音搜索
            guard syllables.count > 1 else { continue }
        
//            queue.async(group: group) {


                let pinyin_i = PyString.pinyin2iList(from: syllables)//截取前三两个个拼音作搜索
                let s = LoginputEngineLib.shared.getPhrase(from: pinyin_i)
                if !s.isEmpty{
                    let ct = CodeTable(Code: syllables.joined(), Table:s)
                    result.append(ct)
            
                    }
                else{
                    
                    var expandResult: CodeTableArray = []
                    queue.async(group: group) {



                        expandResult = self.dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: self.inputBuffer, withLimit: 30, fullpylist: pinyin_i)//扩展词库
                        if expandResult.isEmpty, !self.configManager.disableDatabase {
                            let s = LoginputEngineLib.shared.getPhrase(from: pinyin_i)
                            if !s.isEmpty {
                                expandResult.append(CodeTable(Table: s))
                            }
                        }
                        expandResult.forEach {
                            $0.from.insert(.main)
                            $0.code = self.inputBuffer
                            $0.pyList = pinyin.syllablesList
                        }

                        guard pinyin.syllablesList.count <= 6, var c = self.dictDB.getCodeTableFromFuture(fromCode: self.inputBuffer, fullpylist: pinyin_i) else { return }

                        c.from.insert(.main)
                        c.code = self.inputBuffer

                        if expandResult.count > 1 {
                            expandResult.insert(c, at: 2)
                        } else {
                            expandResult.append(c)
                        }
                    }
                    result.append(contentsOf: expandResult)
                    
                }
//            }
            
        }
        
        if result.isEmpty {//如果结果为空，再用数据库查一遍
            let syllables = pinyin.syllablesList
            let pinyin_i = PyString.pinyin2iList(from: syllables)
            result = self.dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: self.inputBuffer, withLimit: 30, fullpylist: pinyin_i)

        }
        return result
    }
    
    func fullSpellResult(pinyins:Pinyins) -> CodeTableArray{
        // 整句搜索，每个pinyins，在不切分的情况下搜索到的词语
        var result: CodeTableArray = []
        
        for pinyin in pinyins.pinyins{
            let pinyin_i = PyString.pinyin2iList(from: pinyin.syllablesList)
            let s = LoginputEngineLib.shared.getPhrase(from: pinyin_i)
            if !s.isEmpty{
                let ct = CodeTable(Code: self.inputBuffer, Table:s)
                result.append(ct)
            }
            
        }
        
        return result
    }
    
    
    func getSubResult(SubBuffer pinyin: [[String]], pathNumber: Int, subBuffer pinyins:Pinyins) -> CodeTableArray {
        
        guard pathNumber > 0 else { return [] } //数据库查询用的
        var result: CodeTableArray = []
        
        let group = DispatchGroup()//作用？

//        let pinyin_i = PyString.pyList2i(from: pinyin) //拼音转为code
        let pinyin_i = pinyins.getSyllablesIntList(index: 0) // 所有第一个拼音的代码， kei，lei，ke，le

        var userCodeTable: CodeTableArray = []
        queue.async(group: group) {//用户词库查词
            guard self.configManager.userDict else { return }
            userCodeTable = self.dictDB.getCodeTableOrderedByWeightInUserDB(fromCode: self.inputBuffer) //inputBuffer 为 pinyin 53424

            guard self.configManager.quanPin else { return }
            userCodeTable.forEach { $0.from.insert(.main) }
        }
        var appendDict: CodeTableArray = []
        queue.async {//？9键词语
            appendDict = Database.shared.getWordsFromT9Dict(nums: self.inputBuffer)
        }
//        var codeTable:CodeTableArray = []
//        queue.async(group: group) {
//            guard !self.normalSP else {return}
//            codeTable = self.dictDB.getCodeTableOrderedByWeight(fromCode: self.inputBuffer)
//            if self.configManager.revealCode  {
//                let table = self.dictDB.getCodeTableOrderedByWeight(fromCode: self.inputBuffer,asPrefix: true)
//                codeTable += Array(table.prefix(pathNumber))
//            } else {
//                if codeTable.isEmpty && self.configManager.emptySlide {
//                    let cts = self.dictDB.getCodeTableOrderedByWeight(fromCode: self.inputBuffer,asPrefix: true)
//                    codeTable = !cts.isEmpty ? [cts[0]] : []
//                }
//            }
//        }

        var expandResult: CodeTableArray = [] //这个表是单个拼音的表，是fullsentence之外的第一个字的表
        queue.async(group: group) {
            guard pinyin.count == self.pinyin.count else {//通过检测传入的pinyin是否和self.pinyin一致来判断是否需要从单个字的表中查询 传入为【kei，lei】 self.pinyin:[[kei lei],[bi ai ci ch]]
                let s = (pinyin.map { $0[0] }).joined() //s是第一个单个拼音的 string s:keich pinyin：[kei,lei]
                expandResult = self.dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: s, withLimit: pathNumber, fullpylist: pinyin_i) //？主要是用pinyin_i，也就是所有拼音的数字码表，fromcode 是从cache中得到结果

                guard self.configManager.quanPin else { return }

                expandResult.forEach {
                    $0.from.insert(.main)
                    $0.code = s
                }

                return
            }

            guard pinyin.count != 1 else {
                let py = PyString.py2fuzzy(pyList: pinyin, config: self.configManager)
                self.processSingle(fuzzedPinyin: py, list: &expandResult)
                return
            }

            expandResult = self.dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: self.inputBuffer, withLimit: pathNumber, fullpylist: pinyin_i)

            expandResult.sort { $0.weight > $1.weight }

            if expandResult.isEmpty { // if no words in database,use dag instead.
                self.dag(pyList: pinyin, result: &expandResult)
            }
            guard self.configManager.quanPin else { return }
            expandResult.forEach {
                $0.from.insert(.main)
                $0.code = self.inputBuffer
            }

            guard pinyins.getSyllablesCount(index: 0) <= 6, var c = self.dictDB.getCodeTableFromFuture(fromCode: self.inputBuffer, fullpylist: pinyin_i)
            else { return }
            // c是一个codeTable 可以加入总的table中
            if self.configManager.quanPin {
                c.from.insert(.main)
                c.code = self.inputBuffer//code是输入的buffer，就是输入的字符
            }

            if expandResult.count > 1 {
                expandResult.insert(c, at: 2)
            } else {
                expandResult.append(c) //c是‘可以’ expend为‘雷车’
            }
        }

        var superJPResult: CodeTableArray = []
        queue.async(group: group) {
            guard self.configManager.superSP, pinyin == self.pinyin else { return }
            superJPResult = self.dictDB.getCodeTableOrderedByWeightInExpandDBSuperSP(fromCode: self.inputBuffer, fullpylist: pinyin_i)

            guard self.configManager.quanPin else { return }
            superJPResult.forEach {
                $0.from.insert(.main)
                $0.code = self.inputBuffer
            }
        }

        // 等待并发组执行完毕
        let status = group.wait(timeout: DispatchTime.now() + 0.5)
        guard status == .success else { return [] }

//        if configManager.codetableInUserDict {
//            result.append(contentsOf: userCodeTable)
//            //码表一定要优先，然后才是词频
//            result.append(contentsOf: codeTable)
//        } else {
//            result.append(contentsOf: codeTable)
        // 码表一定要优先，然后才是词频
        result.append(contentsOf: userCodeTable)
//        }

        result.append(contentsOf: appendDict)
        result.append(contentsOf: superJPResult)// 简拼

        result.append(contentsOf: expandResult)

        return result
    }

    func dag(pyList: [[String]], pathNum: Int = 5, result: inout CodeTableArray) {
        guard !pyList.isEmpty else { return }

        var D: [Int: PriorityStack<DagNode>] = [:]

        for toIndex in 0 ..< pyList.count {
            let subA = Array(pyList.prefix(toIndex + 1))
            var subCode = ""
            for l in subA {
                subCode += "'\(l[0])"
            }
            let wordAndWeight = dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: subCode, withLimit: pathNum, dag: true, fullpylist: PyString.pyList2i(from: subA))
            for item in wordAndWeight {
                let dagNode = DagNode()
                dagNode.path = [item.table]// item:类
                dagNode.weight = item.weight
                if D[toIndex] == nil {
                    D[toIndex] = PriorityStack(Length: pathNum)
                }
                D[toIndex]?.push(dagNode)
            }
        }

        for fromIndex in 1 ..< pyList.count {
            guard let prevPath = D[fromIndex - 1] else {
                break
            }
            for toIndex in fromIndex ..< pyList.count {
                let range = Range(fromIndex ... toIndex)
                let subA = Array(pyList[range])
                var subCode = ""
                for l in subA {
                    subCode += "'\(l[0])"
                }
                let wordAndWeight = dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: subCode, withLimit: pathNum, dag: true, fullpylist: PyString.pyList2i(from: subA))

                for prevItem in prevPath {
                    for item in wordAndWeight {//item是字和权重
                        let dagNode = DagNode()
                        dagNode.path = prevItem.path + [item.table] //prevItem也是字和权重
                        dagNode.weight = prevItem.weight * item.weight
                        if D[toIndex] == nil {
                            D[toIndex] = PriorityStack(Length: pathNum)
                        }
                        D[toIndex]!.push(dagNode)
                    }
                }
            }
        }
        for index in (0 ..< pyList.count).reversed() {
            guard let result1 = D[index], let one = result1.peek() else { continue }//result1 是五个item
            result = [CodeTable(Table: one.path.joined(separator: ""))]//one是gettop得到的 //result是‘雷车’
            break
        }
    }
}
