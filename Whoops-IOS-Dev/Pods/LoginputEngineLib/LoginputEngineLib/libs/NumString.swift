//
//  NumString.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/16/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import Foundation

public final class NumString {
    fileprivate static let _dict:[String:[Py]] = [
        "534": [PyCombo.kei , PyCombo.lei ],
        "94264": [PyCombo.zhang , PyCombo.xiang ],
        "4826": [PyCombo.guan , PyCombo.huan ],
        "34": [YunMu.ei , PyCombo.di ],
        "486": [PyCombo.guo , PyCombo.huo , PyCombo.gun , PyCombo.hun ],
        "634": [PyCombo.nei , PyCombo.mei ],
        "942": [PyCombo.zha , PyCombo.xia ],
        "436": [PyCombo.hen , PyCombo.gen ],
        "248264": [PyCombo.chuang ],
        "336": [PyCombo.fen , PyCombo.den ],
        "726": [PyCombo.pao , PyCombo.ran , PyCombo.san , PyCombo.rao , PyCombo.sao , PyCombo.pan ],
        "4364": [PyCombo.geng , PyCombo.heng ],
        "946": [PyCombo.xin , PyCombo.yin ],
        "6264": [PyCombo.nang , PyCombo.mang ],
        "3264": [PyCombo.fang , PyCombo.dang ],
        "926": [PyCombo.yao , PyCombo.wan , PyCombo.yan , PyCombo.zao , PyCombo.zan ],
        "8664": [PyCombo.tong ],
        "7364": [PyCombo.seng , PyCombo.peng , PyCombo.reng ],
        "626": [PyCombo.nao , PyCombo.nan , PyCombo.mao , PyCombo.man ],
        "8364": [PyCombo.teng ],
        "643": [PyCombo.nie , PyCombo.mie ],
        "83": [PyCombo.te ],
        "668": [PyCombo.nou , PyCombo.mou ],
        "786": [PyCombo.run , PyCombo.suo , PyCombo.sun , PyCombo.qun , PyCombo.ruo ],
        "384": [PyCombo.dui ],
        "343": [PyCombo.die ],
        "63": [PyCombo.ne , PyCombo.me ],
        "78": [PyCombo.pu , PyCombo.qu , PyCombo.su , PyCombo.ru ],
        "224": [PyCombo.bai , PyCombo.cai ],
        "736": [PyCombo.pen , PyCombo.sen , PyCombo.ren ],
        "286": [PyCombo.cun , PyCombo.cuo ],
        "7436": [PyCombo.shen ],
        "843": [PyCombo.tie ],
        "26": [PyCombo.bo , YunMu.ao , YunMu.an ],
        "5426": [PyCombo.liao , PyCombo.lian , PyCombo.jiao , PyCombo.jian ],
        "886": [PyCombo.tun , PyCombo.tuo ],
        "9426": [PyCombo.zhan , PyCombo.xian , PyCombo.xiao , PyCombo.zhao ],
        "284": [PyCombo.cui ],
        "9486": [PyCombo.zhun , PyCombo.zhuo ],
        "36": [YunMu.en , PyCombo.fo ],
        "924": [PyCombo.zai , PyCombo.wai ],
        "782": [PyCombo.rua ],
        "2264": [PyCombo.cang , PyCombo.bang ],
        "7426": [PyCombo.shan , PyCombo.qiao , PyCombo.piao , PyCombo.pian , PyCombo.qian , PyCombo.shao ],
        "586": [PyCombo.kun , PyCombo.lun , PyCombo.kuo , PyCombo.jun , PyCombo.luo ],
        "2464": [PyCombo.bing ],
        "246": [PyCombo.bin ],
        "768": [PyCombo.sou , PyCombo.rou , PyCombo.pou ],
        "834": [PyCombo.tei ],
        "7424": [PyCombo.shai ],
        "3364": [PyCombo.deng , PyCombo.feng ],
        "364": [YunMu.eng ],
        "74824": [PyCombo.shuai ],
        "734": [PyCombo.pei , PyCombo.sei ],
        "92": [PyCombo.wa , PyCombo.ya , PyCombo.za ],
        "7484": [PyCombo.shui ],
        "54": [PyCombo.li , PyCombo.ji ],
        "3826": [PyCombo.duan ],
        "324": [PyCombo.dai ],
        "746": [PyCombo.pin , PyCombo.qin ],
        "948264": [PyCombo.zhuang ],
        "326": [PyCombo.fan , PyCombo.dan , PyCombo.dao ],
        "2664": [PyCombo.cong ],
        "468": [PyCombo.hou , PyCombo.gou ],
        "58": [PyCombo.ku , PyCombo.lv , PyCombo.lu , PyCombo.ju ],
        "636": [PyCombo.men , PyCombo.nen ],
        "52": [PyCombo.ka , PyCombo.la ],
        "743": [PyCombo.qie , PyCombo.pie , PyCombo.she ],
        "96": [PyCombo.yo , PyCombo.wo ],
        "94364": [PyCombo.zheng ],
        "5664": [PyCombo.kong , PyCombo.long ],
        "243": [PyCombo.che , PyCombo.bie ],
        "4264": [PyCombo.gang , PyCombo.hang ],
        "9484": [PyCombo.zhui ],
        "2486": [PyCombo.chun , PyCombo.chuo ],
        "584": [PyCombo.kui ],
        "542": [PyCombo.lia , PyCombo.jia ],
        "73": [PyCombo.se , PyCombo.re ],
        "9826": [PyCombo.yuan , PyCombo.zuan , PyCombo.xuan ],
        "8464": [PyCombo.ting ],
        "43": [PyCombo.he , PyCombo.ge ],
        "546": [PyCombo.jin , PyCombo.lin ],
        "9464": [PyCombo.ying , PyCombo.xing ],
        "334": [PyCombo.fei , PyCombo.dei ],
        "66": [PyCombo.mo ],
        "62": [PyCombo.na , PyCombo.ma ],
        "6826": [PyCombo.nuan ],
        "2424": [PyCombo.chai ],
        "74364": [PyCombo.sheng ],
        "28": [PyCombo.cu , PyCombo.bu ],
        "7486": [PyCombo.shuo , PyCombo.shun ],
        "6426": [PyCombo.niao , PyCombo.nian , PyCombo.miao , PyCombo.mian ],
        "583": [PyCombo.jue , PyCombo.lue ],
        "748": [PyCombo.shu , PyCombo.qiu ],
        "74": [PyCombo.si , PyCombo.ri , PyCombo.qi , PyCombo.pi , ShengMu.sh ],
        "2364": [PyCombo.beng , PyCombo.ceng ],
        "9424": [PyCombo.zhai ],
        "98": [PyCombo.xu , PyCombo.wu , PyCombo.yu , PyCombo.zu ],
        "72": [PyCombo.pa , PyCombo.sa ],
        "948": [PyCombo.zhu , PyCombo.xiu ],
        "434": [PyCombo.gei , PyCombo.hei ],
        "783": [PyCombo.que ],
        "648": [PyCombo.niu , PyCombo.miu ],
        "582": [PyCombo.kua ],
        "226": [PyCombo.can , PyCombo.cao , PyCombo.ban , PyCombo.bao ],
        "24664": [PyCombo.chong ],
        "84": [PyCombo.ti ],
        "9664": [PyCombo.yong , PyCombo.zong ],
        "94826": [PyCombo.zhuan ],
        "268": [PyCombo.cou ],
        "686": [PyCombo.nun , PyCombo.nuo ],
        "53": [PyCombo.ke , PyCombo.le ],
        "7464": [PyCombo.ping , PyCombo.qing ],
        "5264": [PyCombo.kang , PyCombo.lang ],
        "24": [PyCombo.bi , YunMu.ai , PyCombo.ci , ShengMu.ch ],
        "8826": [PyCombo.tuan ],
        "2482": [PyCombo.chua ],
        "934": [PyCombo.wei , PyCombo.zei ],
        "7468": [PyCombo.shou ],
        "7434": [PyCombo.shei ],
        "68": [YunMu.ou , PyCombo.nv , PyCombo.mu , PyCombo.nu ],
        "5364": [PyCombo.leng , PyCombo.keng ],
        "76": [PyCombo.po ],
        "386": [PyCombo.duo , PyCombo.dun ],
        "986": [PyCombo.yun , PyCombo.zun , PyCombo.xun , PyCombo.zuo ],
        "426": [PyCombo.han , PyCombo.hao , PyCombo.gao , PyCombo.gan ],
        "568": [PyCombo.lou , PyCombo.kou ],
        "868": [PyCombo.tou ],
        "3664": [PyCombo.dong , PyCombo.fong ],
        "524": [PyCombo.lai , PyCombo.kai ],
        "54264": [PyCombo.liang , PyCombo.jiang ],
        "4824": [PyCombo.guai , PyCombo.huai ],
        "342": [PyCombo.dia ],
        "88": [PyCombo.tu ],
        "8426": [PyCombo.tian , PyCombo.tiao ],
        "74826": [PyCombo.shuan ],
        "22": [PyCombo.ca , PyCombo.ba ],
        "24826": [PyCombo.chuan ],
        "683": [PyCombo.nue ],
        "48": [PyCombo.hu , PyCombo.gu ],
        "6664": [PyCombo.nong ],
        "7264": [PyCombo.sang , PyCombo.pang , PyCombo.rang ],
        "42": [PyCombo.ga , PyCombo.ha ],
        "74264": [PyCombo.shang , PyCombo.qiang ],
        "93": [PyCombo.ye , PyCombo.ze ],
        "543": [PyCombo.jie , PyCombo.lie ],
        "368": [PyCombo.dou , PyCombo.fou ],
        "64": [PyCombo.ni , PyCombo.mi ],
        "94": [PyCombo.yi , PyCombo.zi , PyCombo.xi , ShengMu.zh ],
        "7826": [PyCombo.quan , PyCombo.suan , PyCombo.ruan ],
        "2484": [PyCombo.chui ],
        "37": [YunMu.er ],
        "6364": [PyCombo.meng , PyCombo.neng ],
        "348": [PyCombo.diu ],
        "526": [PyCombo.lao , PyCombo.kan , PyCombo.kao , PyCombo.lan ],
        "2426": [PyCombo.biao , PyCombo.bian , PyCombo.chan , PyCombo.chao ],
        "826": [PyCombo.tao , PyCombo.tan ],
        "24264": [PyCombo.chang ],
        "4664": [PyCombo.hong , PyCombo.gong ],
        "9364": [PyCombo.zeng , PyCombo.weng ],
        "784": [PyCombo.rui , PyCombo.sui ],
        "484": [PyCombo.gui , PyCombo.hui ],
        "548": [PyCombo.liu , PyCombo.jiu ],
        "264": [YunMu.ang ],
        "236": [PyCombo.cen , PyCombo.ben ],
        "5464": [PyCombo.ling , PyCombo.jing ],
        "9436": [PyCombo.zhen ],
        "724": [PyCombo.sai , PyCombo.pai ],
        "6464": [PyCombo.ning , PyCombo.ming ],
        "3426": [PyCombo.diao , PyCombo.dian , PyCombo.fiao ],
        "38": [PyCombo.fu , PyCombo.du ],
        "2468": [PyCombo.chou ],
        "33": [PyCombo.de ],
        "9468": [PyCombo.zhou ],
        "646": [PyCombo.min , PyCombo.nin ],
        "824": [PyCombo.tai ],
        "944": [PyCombo.zhi ],
        "983": [PyCombo.yue , PyCombo.xue ],
        "94664": [PyCombo.xiong , PyCombo.zhong ],
        "5826": [PyCombo.luan , PyCombo.juan , PyCombo.kuan ],
        "9264": [PyCombo.zang , PyCombo.yang , PyCombo.wang ],
        "884": [PyCombo.tui ],
        "943": [PyCombo.zhe , PyCombo.xie ],
        "3464": [PyCombo.ding ],
        "9482": [PyCombo.zhua ],
        "94824": [PyCombo.zhuai ],
        "482": [PyCombo.hua , PyCombo.gua ],
        "244": [PyCombo.chi ],
        "48264": [PyCombo.huang , PyCombo.guang ],
        "2826": [PyCombo.cuan ],
        "2": [YunMu.a , ShengMu.b , ShengMu.c ],
        "936": [PyCombo.zen , PyCombo.wen ],
        "32": [PyCombo.fa , PyCombo.da ],
        "23": [PyCombo.ce ],
        "742": [PyCombo.sha , PyCombo.qia ],
        "24364": [PyCombo.cheng ],
        "7664": [PyCombo.rong , PyCombo.song ],
        "7482": [PyCombo.shua ],
        "58264": [PyCombo.kuang ],
        "624": [PyCombo.nai , PyCombo.mai ],
        "968": [PyCombo.zou , PyCombo.you ],
        "424": [PyCombo.gai , PyCombo.hai ],
        "536": [PyCombo.ken ],
        "984": [PyCombo.zui ],
        "24824": [PyCombo.chuai ],
        "242": [PyCombo.cha ],
        "744": [PyCombo.shi ],
        "248": [PyCombo.chu ],
        "3": [YunMu.e , ShengMu.f , ShengMu.d ],
        "5824": [PyCombo.kuai ],
        "748264": [PyCombo.shuang ],
        "82": [PyCombo.ta ],
        "2436": [PyCombo.chen ],
        "54664": [PyCombo.jiong ],
        "8264": [PyCombo.tang ],
        "234": [PyCombo.bei ],
        "64264": [PyCombo.niang ],
        "74664": [PyCombo.qiong ],
        "6": [YunMu.o , ShengMu.m , ShengMu.n ],
        "7": [ShengMu.p , ShengMu.q , ShengMu.r , ShengMu.s ],
        "8": [ShengMu.t ],
        "5": [ShengMu.l , ShengMu.k , ShengMu.j ],
        "4": [ShengMu.g , ShengMu.h ],
        "9": [ShengMu.x , ShengMu.w , ShengMu.y , ShengMu.z ]
    ]
    
    public static func num2py(n:String) ->[Py]? {
        return _dict[n]
    }
    
}
public extension NumString {
    
//    static func nums2pylist(n:String, reverse:Bool = false) ->[[String]] {
//        let l = nums2pylist_i(n: n, reverse: reverse)
//        return PyString.pyList2s(from: l)
//
//    }
    
    static func nums2pylist(n:String) -> Pinyins {
        let pinyins = Pinyins(n: n)
        return pinyins
    }
    
    static func nums2pylist(n:String, reverse:Bool = false) -> [[String]] {
        let pinyins = Pinyins(n: n)
        let newpy =  pinyins.getOriginalPinyins()
        let l = nums2pylist_i(n: n, reverse: reverse)
        let py =  PyString.pyList2s(from: l)
        return py

    }


    static func nums2pylist_i(n:String, reverse:Bool = false) ->[[Py]] {
        let nList = n.components(separatedBy: "'") // nList 是数字串 这是为了支持拼音分隔符
        var result:[[Py]] = []    //返回的记大过是拼音列表

        for num in nList {
            var lastIndex = 0
            while lastIndex < num.count {
                guard !reverse else {break}
                for index in (lastIndex...num.count).reversed() {
                    let sub = num.subString(from: lastIndex, to: index)
                    if let r = num2py(n: sub) { //查表 r 是否在拼音列表中
                        result.append(r)
                        lastIndex = index
                        break
                    }
                }
                if lastIndex == 0 {
                    break
                    // shouldn't be here if n is not empty.
                }
            }
            lastIndex = num.count
            while lastIndex >= 0 {
                guard reverse else {break}

                for index in 0...lastIndex {
                    let sub = num.subString(from: index, to: lastIndex)
                    if let r = num2py(n: sub) {
                        result.append(r)
                        lastIndex = index
                        break
                    }
                }
                if lastIndex == 0 {
                    break
                    // shouldn't be here if n is not empty.
                }
            }
        }
        if reverse {result.reverse()}
        return result
    }
}
