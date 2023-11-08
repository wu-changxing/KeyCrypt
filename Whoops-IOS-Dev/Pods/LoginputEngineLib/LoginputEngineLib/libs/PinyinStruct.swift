//
//  PinyinStruct.swift
//  LoginputEngineLib
//
//  Pinyins 如文档中所描述的，是为了让所有可选的拼音放在一起排序，而重构的数据结构
//
//  Created by changxing on 5/28/21.
//
//

import Foundation
public class Pinyins {
    //初始化
    public init(n numStr:String) {
        self.numStr = numStr
        self.pinyins  = getPinyins(numStr: numStr)
    }
    
    var numStr:String = ""
    public var pinyins:[Pinyin] = [Pinyin(numStr: "", syllables: [:], surface: "", syllablesList: [], syllablesIntList: [])]
    
    // 单个拼音的数据结构
    public struct Pinyin {
        var numStr:String //拼音分隔后的字符串 如 ‘534’24‘ 或者 ’53‘424’
        var syllables:[String:String] //音节字典列表 例如['534':'lei''24':'bi']
        public var surface:String //当前的候选拼音，整句搜索引擎需要的朋友，变量名是和android端统一的
        public var syllablesList:[String]
        public var syllablesIntList:[Py] //存储拼音的Int格式，方便查询，不用二次转化
        public var Droped = false //当用户自己选择拼音后，标志这个拼音的分词路径是否被废弃
    }
    
    //当有新音节需要插入 由func generatePinyins() 调用
    func insertNewSyllables(sub numStr:String,  syllablesList:[Py], priorNumStr:String, result originalPinyins:[Pinyin]) -> [Pinyin] {
        
        var result = originalPinyins
        
        if priorNumStr == "" { //当前originalPinyin 为空 需要加入第一个拼音
            for (_,e) in syllablesList.enumerated(){ //按照顺序保存 i 为序号 e 为拼音
                var tmp = Pinyin(numStr: "", syllables: [:], surface: "", syllablesList: [], syllablesIntList: [])
                let key = numStr //拼音数字
                let value = PyString.i2s(from: e) //拼音
                tmp.numStr.append(numStr)
                tmp.syllables[key] = value
                tmp.surface.append(value+"'")
                tmp.syllablesList.append(value)
                tmp.syllablesIntList.append(e)
                result.append(tmp)
                }
        }// if-end
        else{ // priorNumStr is not ""
            for (index, pinyin) in originalPinyins.enumerated(){ //originalPinyins 与 result 在相同的index处 更新数据
                    if pinyin.numStr == priorNumStr {//前面的数字相同，在之前的拼音序列上跟新，priorNumStr为空，则如上面的加入第一个拼音
                        result[index].numStr.append(numStr) //对于原来就存在的pinyin也更新numStr
                        for (i,e) in syllablesList.enumerated(){ //按照顺序保存 i 为序号 e 为拼音 这是为所有可能的第二第三个拼音分叉
                            let key = numStr //拼音数字
                            let value = PyString.i2s(from: e) //拼音
                            if i > 0 { //每个可能性添加一个 pinyin
                                var tmp = pinyin //预备着为新增加的可能的拼音
                                tmp.numStr.append(numStr) //先变成 53424
                                tmp.syllables.updateValue(value, forKey: key)
                                tmp.surface.append(value+"'")
                                tmp.syllablesList.append(value)
                                tmp.syllablesIntList.append(e)
                                result.append(tmp)
                            }
                            else if i == 0 { //如果syllablesList 也即返回的Py只有一个可能性，或者第一个只改变原有拼音的第一个
                                result[index].syllables.updateValue(value, forKey: key)
                                result[index].surface.append(value+"'")
                                result[index].syllablesList.append(value)
                                result[index].syllablesIntList.append(e)
                            }
                        
                        }//for-loop syllablesList
                    }
            }//for-loop index pinyin
        } // else end
        return result
    }
    
    
    func selectSurface(syllable:String){
    
//        Droped(pinyin)
    }

    
    //根据数字生成pinyins的数据结构
    func getPinyins(numStr:String) -> [Pinyin] {
        var pinyins:[Pinyin] = []
        pinyins+=(generatePinyins(numStr: numStr, result: pinyins)) // 按顺序来一遍
        return pinyins
    }
    
    public func getSyllablesInt(index:Int) -> [Int] {
        return pinyins[index].syllablesIntList
    }
    
    
    public func getSyllablesCount(index:Int) -> Int { //获取音节个数
        return pinyins[index].syllables.count
    }
    
    public subscript(index:Int) -> Pinyin { //pinyins 的下标
        return pinyins[index]
    }
    public func getAllpinyins() -> [Pinyin]{
        return pinyins
    }
    public func getFistSyllables() -> [String] {
        var result:[String] = []
        for pinyin in pinyins{
            guard pinyin.syllables.first?.value != "" else {
                continue
            }
            result.append(pinyin.syllablesList.first!)
        }
        return result.unique
    }
    
    public func getSyllablesIntList(index:Int) -> [[Py]]{
        var result:[Py] = []
        for pinyin in pinyins{
            guard pinyin.syllables.first?.value != "" else {
                continue
            }
            result.append(pinyin.syllablesIntList[index])
        }
        result = result.unique
        return [result]
    }
    
    public func getSyllablesByIndex(index:Int) -> [String]{
        let result = pinyins[index].syllablesList
        return result
    }
    public func getSyllablesIntByIndex(index:Int) -> PyList{
        let result = pinyins[index].syllablesIntList
        return [result]
    }
    
    public func getAllSyllablesInt() -> PyList{
        let result = pinyins.map{
            $0.syllablesIntList
        }
        return result
    }
    
    public func getAllSyllables() -> [[String]]{
        let result = pinyins.map{
            $0.syllablesList
        }
        return result
    }
    
    //递归生成所有拼音的情况
    func generatePinyins(numStr:String, prior:String = "",result pinyins:[Pinyin] ) -> [Pinyin] {
        //        获取拼音序列，也即 53424 要分成 534‘24 的情况 或者 53’424 的情况
        //        原来的变量 n 修改为 numStr 和安卓端统一
        let nList = numStr.components(separatedBy: "'")
        var result:[Pinyin] = pinyins
        var priorNumStr = prior
        
        for num in nList{
            var lastIndex = 0
                for index in (lastIndex...num.count).reversed() {
                    let sub = num.subString(from: lastIndex, to: index)
                    if let r = NumString.num2py(n: sub) { //查表 r 是否在拼音列表中
                        priorNumStr += num.subString(from:0, to: lastIndex)
                        let remainNumStr = num.subString(from: index, to: num.count)
                        result = insertNewSyllables(sub: sub, syllablesList: r, priorNumStr: priorNumStr, result: result)
                        lastIndex = index
                        if lastIndex < num.count{
                            priorNumStr += sub //这里把当前已经用掉的numStr加入pior
                            result =  generatePinyins(numStr: remainNumStr, prior: priorNumStr,result: result)
                        }
                        break
                    }
                }
                if lastIndex == 0 {
                    break
                    // shouldn't be here if n is not empty.
                }


            var firstIndex = 0

            for index in firstIndex...num.count{
                priorNumStr  = prior
                let sub = num.subString(from: firstIndex, to: index)
                    
                let remainNumStr = num.subString(from: index, to: num.count)
                if sub.count == 1 && priorNumStr == ""{
                    continue //
                }
                if let r = NumString.num2py(n: sub){
                    priorNumStr += num.subString(to: firstIndex)
                    result = insertNewSyllables(sub: sub, syllablesList: r, priorNumStr: priorNumStr, result: result)
                    firstIndex = index //跳过一整个拼音
                    if firstIndex < num.count{
                        priorNumStr += sub
                        result = generatePinyins(numStr: remainNumStr, prior: priorNumStr,result: result)
                    } // if-recursive-End
                }// if-getPy-end
            } //for-index-End

        }//for-num in nList-End

        return result
    }

 
    
    
    
    
 //旧的循环，现在使用递归，该方法只能用于测试调试，不能实际使用，部分case有逻辑问题
    func generatePinyinsLoop(numStr:String, reverse:Bool = false) -> [Pinyin] {

        let nList = numStr.components(separatedBy: "'") // nList 是数字串 这是为了支持拼音分隔符
        var result:[Pinyin]  = []  //返回的是多个拼音
        for num in nList {
            var lastIndex = 0
            while lastIndex < num.count {
                guard !reverse else {break}
                for index in (lastIndex...num.count).reversed() {
                    let sub = num.subString(from: lastIndex, to: index)
                    let priorNumStr = num.subString(from:0, to: lastIndex)
                    if let r = NumString.num2py(n: sub) { //查表 r 是否在拼音列表中
                        result = insertNewSyllables(sub: sub, syllablesList: r, priorNumStr: priorNumStr, result: result)
                        lastIndex = index
                        break
                    }
                }
                if lastIndex == 0 {
                    break
                    // shouldn't be here if n is not empty.
                }
            }


            var firstIndex = 0
            while firstIndex < num.count{ //从前向后移动
                guard reverse else {
                    break
                }
                guard num.count > 1 else{
                        break
                    }
                for var index in firstIndex...num.count{
                    var sub = num.subString(from: firstIndex, to: index)
                    let priorNumStr = num.subString(to: firstIndex)
                    if sub.count == 1{
                        index+=1
                        sub = num.subString(from: firstIndex, to: index)
                    }
                    if let r = NumString.num2py(n: sub){
                        result = insertNewSyllables(sub: sub, syllablesList: r, priorNumStr: priorNumStr, result: result)
                        firstIndex = index //跳过一整个拼音
                        break
                    }
                }

            }

        }
        if reverse {result.reverse()}
        return result
    }
    
    //调试使用的函数，需要调用旧的数据结构时临时使用
    func getOriginalPinyins() -> [[String]] {
        // 注意！该函数只能用于调试的时候临时调用，如果需要实际使用，请考虑 多种拼音分词路径的情况
        var result:[[String]] = [[]] //和原来的一致
        for (key, _) in pinyins[0].syllables{
            var tmp:[String] = []
            for pinyin in self.pinyins{
                tmp.append(pinyin.syllables[key] ?? "") //例如 key 为 534 则分别有 kei lei
                        
                }
            result.append(tmp)
        }
        return result
    }
}

extension Array where Element: Hashable {
    var unique: [Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(count)
        return filter {
            return uniq.insert($0).inserted
        }
    }
}
