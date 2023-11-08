//
//  PyString.swift
//  test
//
//  Created by Aaron on 11/29/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation
public typealias Py = Int
public typealias PyList = [[Py]]

let kShengMuOffset = 8
let kYunMuMask = 0b111111

public final class ShengMu {
    static let none:Py = 0
    static let b:Py = 01 << kShengMuOffset
    static let p:Py = 02 << kShengMuOffset
    static let m:Py = 03 << kShengMuOffset
    static let f:Py = 04 << kShengMuOffset
    static let d:Py = 05 << kShengMuOffset
    static let t:Py = 06 << kShengMuOffset
    static let n:Py = 07 << kShengMuOffset
    static let l:Py = 08 << kShengMuOffset
    static let g:Py = 09 << kShengMuOffset
    static let k:Py = 10 << kShengMuOffset
    static let h:Py = 11 << kShengMuOffset
    static let j:Py = 12 << kShengMuOffset
    static let q:Py = 13 << kShengMuOffset
    static let x:Py = 14 << kShengMuOffset
    
    static let z:Py = 15 << kShengMuOffset
    static let c:Py = 16 << kShengMuOffset
    static let s:Py = 17 << kShengMuOffset
    static let zh:Py = (15 << kShengMuOffset) | 0b10000000
    static let ch:Py = (16 << kShengMuOffset) | 0b10000000
    static let sh:Py = (17 << kShengMuOffset) | 0b10000000
    
    static let r:Py = 18 << kShengMuOffset
    static let w:Py = 22 << kShengMuOffset
    static let y:Py = 23 << kShengMuOffset
    
}

public final class YunMu {
    
    static let none:Py = 0
    static let ai:Py = 1
    static let ei:Py = 2
    static let ui:Py = 3
    static let ao:Py = 4
    static let ou:Py = 5
    static let iu:Py = 6
    static let ie:Py = 7
    static let ue:Py = 8
    static let er:Py = 9
    static let an:Py = 10
    static let en:Py = 11
    static let `in`:Py = 12
    static let un:Py = 13
    static let ang:Py = 14
    static let eng:Py = 15
    static let ing:Py = 16
    static let ong:Py = 17
    static let ua:Py = 18
    static let uai:Py = 19
    static let uan:Py = 20
    static let uang:Py = 21
    static let iang:Py = 22
    static let iong:Py = 23
    static let iao:Py = 24
    static let ian:Py = 25
    static let uo:Py = 26
    static let ia:Py = 27
    
    static let a:Py = 28
    static let o:Py = 29
    static let e:Py = 30
    static let i:Py = 31
    static let u:Py = 32
    static let v:Py = 33
}


public final class PyCombo {
    static let kei:Py =  ShengMu.k | YunMu.ei
    static let zhang:Py = ShengMu.zh | YunMu.ang
    static let guan:Py = ShengMu.g | YunMu.uan
    static let guo:Py = ShengMu.g | YunMu.uo
    static let nei:Py = ShengMu.n | YunMu.ei
    static let zha:Py = ShengMu.zh | YunMu.a
    static let hen:Py = ShengMu.h | YunMu.en
    static let chuang:Py = ShengMu.ch | YunMu.uang
    static let fen:Py = ShengMu.f | YunMu.en
    static let pao:Py = ShengMu.p | YunMu.ao
    static let geng:Py = ShengMu.g | YunMu.eng
    static let xin:Py = ShengMu.x | YunMu.in
    static let nang:Py = ShengMu.n | YunMu.ang
    static let fang:Py =  ShengMu.f | YunMu.ang
    static let yao:Py = ShengMu.y | YunMu.ao
    static let ran:Py = ShengMu.r | YunMu.an
    static let tong:Py = ShengMu.t | YunMu.ong
    static let seng:Py = ShengMu.s | YunMu.eng
    static let nao:Py = ShengMu.n | YunMu.ao
    static let teng:Py = ShengMu.t | YunMu.eng
    static let nie:Py = ShengMu.n | YunMu.ie
    static let te:Py = ShengMu.t | YunMu.e
    static let nou:Py = ShengMu.n | YunMu.ou
    static let run:Py = ShengMu.r | YunMu.un
    static let dui:Py = ShengMu.d | YunMu.ui
    static let die:Py = ShengMu.d | YunMu.ie
    static let ne:Py = ShengMu.n | YunMu.e
    static let pu:Py = ShengMu.p | YunMu.u
    static let bai:Py = ShengMu.b | YunMu.ai
    static let pen:Py = ShengMu.p | YunMu.en
    static let qu:Py = ShengMu.q | YunMu.u
    static let cun:Py =  ShengMu.c | YunMu.un
    static let shen:Py = ShengMu.sh | YunMu.en
    static let tie:Py = ShengMu.t | YunMu.ie
    static let bo:Py = ShengMu.b | YunMu.o
    static let liao:Py = ShengMu.l | YunMu.iao
    static let tun:Py = ShengMu.t | YunMu.un
    static let zhan:Py = ShengMu.zh | YunMu.an
    static let cui:Py = ShengMu.c | YunMu.ui
    static let zhun:Py = ShengMu.zh | YunMu.un
    static let mie:Py = ShengMu.m | YunMu.ie
    static let zai:Py = ShengMu.z | YunMu.ai
    static let rua:Py = ShengMu.r | YunMu.ua
    static let cang:Py = ShengMu.c | YunMu.ang
    static let shan:Py = ShengMu.sh | YunMu.an
    static let kun:Py = ShengMu.k | YunMu.un
    static let bing:Py = ShengMu.b | YunMu.ing
    static let lian:Py =  ShengMu.l | YunMu.ian
    static let bin:Py = ShengMu.b | YunMu.in
    static let sou:Py = ShengMu.s | YunMu.ou
    static let tei:Py = ShengMu.t | YunMu.ei
    static let di:Py = ShengMu.d | YunMu.i
    static let shai:Py = ShengMu.sh | YunMu.ai
    static let deng:Py = ShengMu.d | YunMu.eng
    static let shuai:Py = ShengMu.sh | YunMu.uai
    static let pei:Py = ShengMu.p | YunMu.ei
    static let wa:Py = ShengMu.w | YunMu.a
    static let shui:Py = ShengMu.sh | YunMu.ui
    static let li:Py = ShengMu.l | YunMu.i
    static let duan:Py = ShengMu.d | YunMu.uan
    static let dai:Py = ShengMu.d | YunMu.ai
    static let gen:Py = ShengMu.g | YunMu.en
    static let suo:Py = ShengMu.s | YunMu.uo
    static let mei:Py =  ShengMu.m | YunMu.ei
    static let san:Py = ShengMu.s | YunMu.an
    static let su:Py = ShengMu.s | YunMu.u
    static let pin:Py = ShengMu.p | YunMu.in
    static let zhuang:Py = ShengMu.zh | YunMu.uang
    static let fan:Py = ShengMu.f | YunMu.an
    static let cong:Py = ShengMu.c | YunMu.ong
    static let huo:Py = ShengMu.h | YunMu.uo
    static let ru:Py = ShengMu.r | YunMu.u
    static let hou:Py = ShengMu.h | YunMu.ou
    static let ku:Py = ShengMu.k | YunMu.u
    static let men:Py = ShengMu.m | YunMu.en
    static let lei:Py = ShengMu.l | YunMu.ei
    static let ka:Py = ShengMu.k | YunMu.a
    static let qie:Py = ShengMu.q | YunMu.ie
    static let yo:Py = ShengMu.y | YunMu.o
    static let zheng:Py = ShengMu.zh | YunMu.eng
    static let kong:Py =  ShengMu.k | YunMu.ong
    static let che:Py = ShengMu.ch | YunMu.e
    static let gang:Py = ShengMu.g | YunMu.ang
    static let yin:Py = ShengMu.y | YunMu.in
    static let zhui:Py = ShengMu.zh | YunMu.ui
    static let chun:Py = ShengMu.ch | YunMu.un
    static let kui:Py = ShengMu.k | YunMu.ui
    static let lia:Py = ShengMu.l | YunMu.ia
    static let se:Py = ShengMu.s | YunMu.e
    static let yuan:Py = ShengMu.y | YunMu.uan
    static let ting:Py = ShengMu.t | YunMu.ing
    static let fo:Py = ShengMu.f | YunMu.o
    static let he:Py = ShengMu.h | YunMu.e
    static let jin:Py = ShengMu.j | YunMu.in
    static let ying:Py = ShengMu.y | YunMu.ing
    static let fei:Py = ShengMu.f | YunMu.ei
    static let mo:Py = ShengMu.m | YunMu.o
    static let wan:Py = ShengMu.w | YunMu.an
    static let na:Py =  ShengMu.n | YunMu.a
    static let nuan:Py = ShengMu.n | YunMu.uan
    static let chai:Py = ShengMu.ch | YunMu.ai
    static let la:Py = ShengMu.l | YunMu.a
    static let sheng:Py = ShengMu.sh | YunMu.eng
    static let cu:Py = ShengMu.c | YunMu.u
    static let hang:Py = ShengMu.h | YunMu.ang
    static let shuo:Py = ShengMu.sh | YunMu.uo
    static let niao:Py = ShengMu.n | YunMu.iao
    static let qiao:Py = ShengMu.q | YunMu.iao
    static let jue:Py = ShengMu.j | YunMu.ue
    static let shu:Py = ShengMu.sh | YunMu.u
    static let si:Py = ShengMu.s | YunMu.i
    static let gou:Py = ShengMu.g | YunMu.ou
    static let beng:Py = ShengMu.b | YunMu.eng
    static let zhai:Py = ShengMu.zh | YunMu.ai
    static let me:Py = ShengMu.m | YunMu.e
    static let xu:Py =  ShengMu.x | YunMu.u
    static let pa:Py = ShengMu.p | YunMu.a
    static let sun:Py = ShengMu.s | YunMu.un
    static let zhu:Py = ShengMu.zh | YunMu.u
    static let lun:Py = ShengMu.l | YunMu.un
    static let gei:Py = ShengMu.g | YunMu.ei
    static let xian:Py = ShengMu.x | YunMu.ian
    static let xiu:Py = ShengMu.x | YunMu.iu
    static let que:Py = ShengMu.q | YunMu.ue
    static let niu:Py = ShengMu.n | YunMu.iu
    static let kua:Py = ShengMu.k | YunMu.ua
    static let can:Py = ShengMu.c | YunMu.an
    static let chong:Py = ShengMu.ch | YunMu.ong
    static let ti:Py = ShengMu.t | YunMu.i
    static let yong:Py = ShengMu.y | YunMu.ong
    static let zhuan:Py = ShengMu.zh | YunMu.uan
    static let piao:Py = ShengMu.p | YunMu.iao
    static let cou:Py =  ShengMu.c | YunMu.ou
    static let xia:Py = ShengMu.x | YunMu.ia
    static let nun:Py = ShengMu.n | YunMu.un
    static let ke:Py = ShengMu.k | YunMu.e
    static let ping:Py = ShengMu.p | YunMu.ing
    static let kang:Py = ShengMu.k | YunMu.ang
    static let bi:Py = ShengMu.b | YunMu.i
    static let tuan:Py = ShengMu.t | YunMu.uan
    static let chua:Py = ShengMu.ch | YunMu.ua
    static let wei:Py = ShengMu.w | YunMu.ei
    static let xiang:Py = ShengMu.x | YunMu.iang
    static let nuo:Py = ShengMu.n | YunMu.uo
    static let shou:Py = ShengMu.sh | YunMu.ou
    static let shei:Py = ShengMu.sh | YunMu.ei
    static let bu:Py = ShengMu.b | YunMu.u
    static let leng:Py = ShengMu.l | YunMu.eng
    static let gun:Py =  ShengMu.g | YunMu.un
    static let po:Py = ShengMu.p | YunMu.o
    static let lue:Py = ShengMu.l | YunMu.ue
    static let yan:Py = ShengMu.y | YunMu.an
    static let duo:Py = ShengMu.d | YunMu.uo
    static let yun:Py = ShengMu.y | YunMu.un
    static let mou:Py = ShengMu.m | YunMu.ou
    static let xing:Py = ShengMu.x | YunMu.ing
    static let xiao:Py = ShengMu.x | YunMu.iao
    static let han:Py = ShengMu.h | YunMu.an
    static let lou:Py = ShengMu.l | YunMu.ou
    static let cai:Py = ShengMu.c | YunMu.ai
    static let nian:Py = ShengMu.n | YunMu.ian
    static let qin:Py = ShengMu.q | YunMu.in
    static let tou:Py = ShengMu.t | YunMu.ou
    static let dong:Py = ShengMu.d | YunMu.ong
    static let lai:Py = ShengMu.l | YunMu.ai
    static let liang:Py =  ShengMu.l | YunMu.iang
    static let ri:Py = ShengMu.r | YunMu.i
    static let guai:Py = ShengMu.g | YunMu.uai
    static let nv:Py = ShengMu.n | YunMu.v
    static let dia:Py = ShengMu.d | YunMu.ia
    static let lv:Py = ShengMu.l | YunMu.v
    static let tu:Py = ShengMu.t | YunMu.u
    static let tian:Py = ShengMu.t | YunMu.ian
    static let qing:Py = ShengMu.q | YunMu.ing
    static let rao:Py = ShengMu.r | YunMu.ao
    static let pian:Py = ShengMu.p | YunMu.ian
    static let shuan:Py = ShengMu.sh | YunMu.uan
    static let ca:Py = ShengMu.c | YunMu.a
    static let zuan:Py = ShengMu.z | YunMu.uan
    static let chuan:Py = ShengMu.ch | YunMu.uan
    static let le:Py = ShengMu.l | YunMu.e
    static let nue:Py = ShengMu.n | YunMu.ue
    static let hu:Py =  ShengMu.h | YunMu.u
    static let nong:Py = ShengMu.n | YunMu.ong
    static let sang:Py = ShengMu.s | YunMu.ang
    static let cuo:Py = ShengMu.c | YunMu.uo
    static let ya:Py = ShengMu.y | YunMu.a
    static let wu:Py = ShengMu.w | YunMu.u
    static let ga:Py = ShengMu.g | YunMu.a
    static let zei:Py = ShengMu.z | YunMu.ei
    static let shang:Py = ShengMu.sh | YunMu.ang
    static let ye:Py = ShengMu.y | YunMu.e
    static let zong:Py = ShengMu.z | YunMu.ong
    static let jie:Py = ShengMu.j | YunMu.ie
    static let dou:Py = ShengMu.d | YunMu.ou
    static let ni:Py = ShengMu.n | YunMu.i
    static let yi:Py = ShengMu.y | YunMu.i
    static let zao:Py = ShengMu.z | YunMu.ao
    static let dan:Py = ShengMu.d | YunMu.an
    static let quan:Py = ShengMu.q | YunMu.uan
    static let rou:Py =  ShengMu.r | YunMu.ou
    static let yu:Py = ShengMu.y | YunMu.u
    static let chui:Py = ShengMu.ch | YunMu.ui
    static let meng:Py = ShengMu.m | YunMu.eng
    static let den:Py = ShengMu.d | YunMu.en
    static let diu:Py = ShengMu.d | YunMu.iu
    static let lao:Py = ShengMu.l | YunMu.ao
    static let qiu:Py = ShengMu.q | YunMu.iu
    static let biao:Py = ShengMu.b | YunMu.iao
    static let tao:Py = ShengMu.t | YunMu.ao
    static let za:Py = ShengMu.z | YunMu.a
    static let chang:Py = ShengMu.ch | YunMu.ang
    static let fong:Py = ShengMu.f | YunMu.ong
    static let bang:Py = ShengMu.b | YunMu.ang
    static let hong:Py = ShengMu.h | YunMu.ong
    static let chuo:Py =  ShengMu.ch | YunMu.uo
    static let fou:Py = ShengMu.f | YunMu.ou
    static let zeng:Py = ShengMu.z | YunMu.eng
    static let rui:Py = ShengMu.r | YunMu.ui
    static let mang:Py = ShengMu.m | YunMu.ang
    static let hei:Py = ShengMu.h | YunMu.ei
    static let gui:Py = ShengMu.g | YunMu.ui
    static let hao:Py = ShengMu.h | YunMu.ao
    static let lie:Py = ShengMu.l | YunMu.ie
    static let neng:Py = ShengMu.n | YunMu.eng
    static let liu:Py = ShengMu.l | YunMu.iu
    static let peng:Py = ShengMu.p | YunMu.eng
    static let jia:Py = ShengMu.j | YunMu.ia
    static let zun:Py = ShengMu.z | YunMu.un
    static let bian:Py = ShengMu.b | YunMu.ian
    static let miu:Py =  ShengMu.m | YunMu.iu
    static let sei:Py = ShengMu.s | YunMu.ei
    static let jiao:Py = ShengMu.j | YunMu.iao
    static let chan:Py = ShengMu.ch | YunMu.an
    static let cen:Py = ShengMu.c | YunMu.en
    static let kan:Py = ShengMu.k | YunMu.an
    static let mi:Py = ShengMu.m | YunMu.i
    static let kou:Py = ShengMu.k | YunMu.ou
    static let ling:Py = ShengMu.l | YunMu.ing
    static let zhen:Py = ShengMu.zh | YunMu.en
    static let sai:Py = ShengMu.s | YunMu.ai
    static let ning:Py = ShengMu.n | YunMu.ing
    static let diao:Py = ShengMu.d | YunMu.iao
    static let fu:Py = ShengMu.f | YunMu.u
    static let chou:Py = ShengMu.ch | YunMu.ou
    static let qian:Py =  ShengMu.q | YunMu.ian
    static let ma:Py = ShengMu.m | YunMu.a
    static let de:Py = ShengMu.d | YunMu.e
    static let zhou:Py = ShengMu.zh | YunMu.ou
    static let tuo:Py = ShengMu.t | YunMu.uo
    static let kuo:Py = ShengMu.k | YunMu.uo
    static let min:Py = ShengMu.m | YunMu.in
    static let tai:Py = ShengMu.t | YunMu.ai
    static let feng:Py = ShengMu.f | YunMu.eng
    static let ze:Py = ShengMu.z | YunMu.e
    static let zhuo:Py = ShengMu.zh | YunMu.uo
    static let dun:Py = ShengMu.d | YunMu.un
    static let jiang:Py = ShengMu.j | YunMu.iang
    static let zhao:Py = ShengMu.zh | YunMu.ao
    static let zhi:Py = ShengMu.zh | YunMu.i
    static let lu:Py = ShengMu.l | YunMu.u
    static let yue:Py = ShengMu.y | YunMu.ue
    static let qun:Py =  ShengMu.q | YunMu.un
    static let jiu:Py = ShengMu.j | YunMu.iu
    static let weng:Py = ShengMu.w | YunMu.eng
    static let xiong:Py = ShengMu.x | YunMu.iong
    static let kao:Py = ShengMu.k | YunMu.ao
    static let luan:Py = ShengMu.l | YunMu.uan
    static let huan:Py = ShengMu.h | YunMu.uan
    static let zang:Py = ShengMu.z | YunMu.ang
    static let long:Py = ShengMu.l | YunMu.ong
    static let tui:Py = ShengMu.t | YunMu.ui
    static let lan:Py = ShengMu.l | YunMu.an
    static let sen:Py = ShengMu.s | YunMu.en
    static let suan:Py = ShengMu.s | YunMu.uan
    static let pang:Py = ShengMu.p | YunMu.ang
    static let jian:Py = ShengMu.j | YunMu.ian
    static let zhe:Py = ShengMu.zh | YunMu.e
    static let zhong:Py =  ShengMu.zh | YunMu.ong
    static let ding:Py = ShengMu.d | YunMu.ing
    static let kai:Py = ShengMu.k | YunMu.ai
    static let zhua:Py = ShengMu.zh | YunMu.ua
    static let nan:Py = ShengMu.n | YunMu.an
    static let lin:Py = ShengMu.l | YunMu.in
    static let keng:Py = ShengMu.k | YunMu.eng
    static let sui:Py = ShengMu.s | YunMu.ui
    static let zhuai:Py = ShengMu.zh | YunMu.uai
    static let hun:Py = ShengMu.h | YunMu.un
    static let dian:Py = ShengMu.d | YunMu.ian
    static let wai:Py = ShengMu.w | YunMu.ai
    static let ming:Py = ShengMu.m | YunMu.ing
    static let bie:Py = ShengMu.b | YunMu.ie
    static let xue:Py = ShengMu.x | YunMu.ue
    static let hua:Py =  ShengMu.h | YunMu.ua
    static let tiao:Py = ShengMu.t | YunMu.iao
    static let qi:Py = ShengMu.q | YunMu.i
    static let ba:Py = ShengMu.b | YunMu.a
    static let chi:Py = ShengMu.ch | YunMu.i
    static let huang:Py = ShengMu.h | YunMu.uang
    static let cuan:Py = ShengMu.c | YunMu.uan
    static let zen:Py = ShengMu.z | YunMu.en
    static let fa:Py = ShengMu.f | YunMu.a
    static let ce:Py = ShengMu.c | YunMu.e
    static let sha:Py = ShengMu.sh | YunMu.a
    static let cheng:Py = ShengMu.ch | YunMu.eng
    static let jun:Py = ShengMu.j | YunMu.un
    static let ruo:Py = ShengMu.r | YunMu.uo
    static let zan:Py = ShengMu.z | YunMu.an
    static let xun:Py = ShengMu.x | YunMu.un
    static let dei:Py = ShengMu.d | YunMu.ei
    static let rong:Py =  ShengMu.r | YunMu.ong
    static let shun:Py = ShengMu.sh | YunMu.un
    static let da:Py = ShengMu.d | YunMu.a
    static let luo:Py = ShengMu.l | YunMu.uo
    static let shua:Py = ShengMu.sh | YunMu.ua
    static let pou:Py = ShengMu.p | YunMu.ou
    static let pie:Py = ShengMu.p | YunMu.ie
    static let gong:Py = ShengMu.g | YunMu.ong
    static let juan:Py = ShengMu.j | YunMu.uan
    static let yang:Py = ShengMu.y | YunMu.ang
    static let kuang:Py = ShengMu.k | YunMu.uang
    static let ruan:Py = ShengMu.r | YunMu.uan
    static let nai:Py = ShengMu.n | YunMu.ai
    static let zou:Py = ShengMu.z | YunMu.ou
    static let you:Py = ShengMu.y | YunMu.ou
    static let gai:Py = ShengMu.g | YunMu.ai
    static let lang:Py =  ShengMu.l | YunMu.ang
    static let ha:Py = ShengMu.h | YunMu.a
    static let ren:Py = ShengMu.r | YunMu.en
    static let mao:Py = ShengMu.m | YunMu.ao
    static let hai:Py = ShengMu.h | YunMu.ai
    static let mu:Py = ShengMu.m | YunMu.u
    static let wang:Py = ShengMu.w | YunMu.ang
    static let re:Py = ShengMu.r | YunMu.e
    static let she:Py = ShengMu.sh | YunMu.e
    static let zuo:Py = ShengMu.z | YunMu.uo
    static let ken:Py = ShengMu.k | YunMu.en
    static let chao:Py = ShengMu.ch | YunMu.ao
    static let zui:Py = ShengMu.z | YunMu.ui
    static let chuai:Py = ShengMu.ch | YunMu.uai
    static let sa:Py = ShengMu.s | YunMu.a
    static let cao:Py = ShengMu.c | YunMu.ao
    static let cha:Py = ShengMu.ch | YunMu.a
    static let dao:Py = ShengMu.d | YunMu.ao
    static let man:Py =  ShengMu.m | YunMu.an
    static let kuan:Py = ShengMu.k | YunMu.uan
    static let shi:Py = ShengMu.sh | YunMu.i
    static let chu:Py = ShengMu.ch | YunMu.u
    static let ban:Py = ShengMu.b | YunMu.an
    static let ci:Py = ShengMu.c | YunMu.i
    static let qia:Py = ShengMu.q | YunMu.ia
    static let sao:Py = ShengMu.s | YunMu.ao
    static let kuai:Py = ShengMu.k | YunMu.uai
    static let mai:Py = ShengMu.m | YunMu.ai
    static let tan:Py = ShengMu.t | YunMu.an
    static let shuang:Py = ShengMu.sh | YunMu.uang
    static let pi:Py = ShengMu.p | YunMu.i
    static let ju:Py = ShengMu.j | YunMu.u
    static let nen:Py = ShengMu.n | YunMu.en
    static let hui:Py = ShengMu.h | YunMu.ui
    static let gua:Py = ShengMu.g | YunMu.ua
    static let ta:Py =  ShengMu.t | YunMu.a
    static let miao:Py = ShengMu.m | YunMu.iao
    static let gao:Py = ShengMu.g | YunMu.ao
    static let qiang:Py = ShengMu.q | YunMu.iang
    static let gu:Py = ShengMu.g | YunMu.u
    static let ji:Py = ShengMu.j | YunMu.i
    static let du:Py = ShengMu.d | YunMu.u
    static let guang:Py = ShengMu.g | YunMu.uang
    static let pan:Py = ShengMu.p | YunMu.an
    static let fiao:Py = ShengMu.f | YunMu.iao
    static let mian:Py = ShengMu.m | YunMu.ian
    static let reng:Py = ShengMu.r | YunMu.eng
    static let huai:Py = ShengMu.h | YunMu.uai
    static let ge:Py = ShengMu.g | YunMu.e
    static let wen:Py = ShengMu.w | YunMu.en
    static let nu:Py = ShengMu.n | YunMu.u
    static let pai:Py = ShengMu.p | YunMu.ai
    static let zi:Py =  ShengMu.z | YunMu.i
    static let nin:Py = ShengMu.n | YunMu.in
    static let ben:Py = ShengMu.b | YunMu.en
    static let song:Py = ShengMu.s | YunMu.ong
    static let gan:Py = ShengMu.g | YunMu.an
    static let bao:Py = ShengMu.b | YunMu.ao
    static let xuan:Py = ShengMu.x | YunMu.uan
    static let chen:Py = ShengMu.ch | YunMu.en
    static let jiong:Py = ShengMu.j | YunMu.iong
    static let zu:Py = ShengMu.z | YunMu.u
    static let tang:Py = ShengMu.t | YunMu.ang
    static let bei:Py = ShengMu.b | YunMu.ei
    static let jing:Py = ShengMu.j | YunMu.ing
    static let xi:Py = ShengMu.x | YunMu.i
    static let ceng:Py = ShengMu.c | YunMu.eng
    static let rang:Py = ShengMu.r | YunMu.ang
    static let niang:Py =  ShengMu.n | YunMu.iang
    static let shao:Py = ShengMu.sh | YunMu.ao
    static let wo:Py = ShengMu.w | YunMu.o
    static let xie:Py = ShengMu.x | YunMu.ie
    static let qiong:Py = ShengMu.q | YunMu.iong
    static let heng:Py = ShengMu.h | YunMu.eng
    static let dang:Py = ShengMu.d | YunMu.ang
    static let lo:Py = ShengMu.l | YunMu.o
}



public final class PyString {
    fileprivate static let i2s_dict:[Py:String] = [
        PyCombo.kei: "kei",
        PyCombo.zhang: "zhang",
        PyCombo.guan: "guan",
        YunMu.ei: "ei",
        PyCombo.guo: "guo",
        PyCombo.nei: "nei",
        PyCombo.zha: "zha",
        PyCombo.hen: "hen",
        PyCombo.chuang: "chuang",
        PyCombo.fen: "fen",
        PyCombo.pao: "pao",
        PyCombo.geng: "geng",
        PyCombo.xin: "xin",
        PyCombo.nang: "nang",
        PyCombo.fang: "fang",
        PyCombo.yao: "yao",
        PyCombo.ran: "ran",
        PyCombo.tong: "tong",
        PyCombo.seng: "seng",
        PyCombo.nao: "nao",
        PyCombo.teng: "teng",
        PyCombo.nie: "nie",
        PyCombo.te: "te",
        PyCombo.nou: "nou",
        PyCombo.run: "run",
        PyCombo.dui: "dui",
        PyCombo.die: "die",
        PyCombo.ne: "ne",
        PyCombo.pu: "pu",
        PyCombo.bai: "bai",
        PyCombo.pen: "pen",
        PyCombo.qu: "qu",
        PyCombo.cun: "cun",
        PyCombo.shen: "shen",
        PyCombo.tie: "tie",
        PyCombo.bo: "bo",
        PyCombo.liao: "liao",
        PyCombo.tun: "tun",
        PyCombo.zhan: "zhan",
        PyCombo.cui: "cui",
        PyCombo.zhun: "zhun",
        YunMu.en: "en",
        PyCombo.mie: "mie",
        PyCombo.zai: "zai",
        PyCombo.rua: "rua",
        PyCombo.cang: "cang",
        PyCombo.shan: "shan",
        PyCombo.kun: "kun",
        PyCombo.bing: "bing",
        PyCombo.lian: "lian",
        PyCombo.bin: "bin",
        PyCombo.sou: "sou",
        PyCombo.tei: "tei",
        PyCombo.di: "di",
        PyCombo.shai: "shai",
        PyCombo.deng: "deng",
        YunMu.eng: "eng",
        PyCombo.shuai: "shuai",
        PyCombo.pei: "pei",
        PyCombo.wa: "wa",
        PyCombo.shui: "shui",
        PyCombo.li: "li",
        PyCombo.duan: "duan",
        PyCombo.dai: "dai",
        PyCombo.gen: "gen",
        PyCombo.suo: "suo",
        PyCombo.mei: "mei",
        PyCombo.san: "san",
        PyCombo.su: "su",
        PyCombo.pin: "pin",
        PyCombo.zhuang: "zhuang",
        PyCombo.fan: "fan",
        PyCombo.cong: "cong",
        PyCombo.huo: "huo",
        PyCombo.ru: "ru",
        PyCombo.hou: "hou",
        PyCombo.ku: "ku",
        PyCombo.men: "men",
        PyCombo.lei: "lei",
        PyCombo.ka: "ka",
        PyCombo.qie: "qie",
        PyCombo.yo: "yo",
        PyCombo.zheng: "zheng",
        PyCombo.kong: "kong",
        PyCombo.che: "che",
        PyCombo.gang: "gang",
        PyCombo.yin: "yin",
        PyCombo.zhui: "zhui",
        PyCombo.chun: "chun",
        PyCombo.kui: "kui",
        PyCombo.lia: "lia",
        PyCombo.se: "se",
        PyCombo.yuan: "yuan",
        PyCombo.ting: "ting",
        PyCombo.fo: "fo",
        PyCombo.he: "he",
        PyCombo.jin: "jin",
        PyCombo.ying: "ying",
        PyCombo.fei: "fei",
        PyCombo.mo: "mo",
        PyCombo.wan: "wan",
        PyCombo.na: "na",
        PyCombo.nuan: "nuan",
        PyCombo.chai: "chai",
        PyCombo.la: "la",
        PyCombo.sheng: "sheng",
        PyCombo.cu: "cu",
        PyCombo.hang: "hang",
        PyCombo.shuo: "shuo",
        PyCombo.niao: "niao",
        PyCombo.qiao: "qiao",
        PyCombo.jue: "jue",
        PyCombo.shu: "shu",
        PyCombo.si: "si",
        PyCombo.gou: "gou",
        PyCombo.beng: "beng",
        PyCombo.zhai: "zhai",
        PyCombo.me: "me",
        PyCombo.xu: "xu",
        PyCombo.pa: "pa",
        PyCombo.sun: "sun",
        PyCombo.zhu: "zhu",
        PyCombo.lun: "lun",
        PyCombo.gei: "gei",
        PyCombo.xian: "xian",
        PyCombo.xiu: "xiu",
        PyCombo.que: "que",
        PyCombo.niu: "niu",
        PyCombo.kua: "kua",
        PyCombo.can: "can",
        PyCombo.chong: "chong",
        PyCombo.ti: "ti",
        PyCombo.yong: "yong",
        PyCombo.zhuan: "zhuan",
        PyCombo.piao: "piao",
        PyCombo.cou: "cou",
        PyCombo.xia: "xia",
        PyCombo.nun: "nun",
        PyCombo.ke: "ke",
        PyCombo.ping: "ping",
        PyCombo.kang: "kang",
        PyCombo.bi: "bi",
        PyCombo.tuan: "tuan",
        PyCombo.chua: "chua",
        PyCombo.wei: "wei",
        PyCombo.xiang: "xiang",
        PyCombo.nuo: "nuo",
        PyCombo.shou: "shou",
        PyCombo.shei: "shei",
        PyCombo.bu: "bu",
        YunMu.ou: "ou",
        
        PyCombo.leng: "leng",
        PyCombo.gun: "gun",
        PyCombo.po: "po",
        PyCombo.lue: "lue",
        PyCombo.yan: "yan",
        PyCombo.duo: "duo",
        PyCombo.yun: "yun",
        PyCombo.mou: "mou",
        PyCombo.xing: "xing",
        PyCombo.xiao: "xiao",
        PyCombo.han: "han",
        PyCombo.lou: "lou",
        PyCombo.cai: "cai",
        PyCombo.nian: "nian",
        PyCombo.qin: "qin",
        PyCombo.tou: "tou",
        PyCombo.dong: "dong",
        PyCombo.lai: "lai",
        PyCombo.liang: "liang",
        PyCombo.ri: "ri",
        PyCombo.guai: "guai",
        PyCombo.nv: "nv",
        PyCombo.dia: "dia",
        PyCombo.lv: "lv",
        PyCombo.tu: "tu",
        PyCombo.tian: "tian",
        PyCombo.qing: "qing",
        PyCombo.rao: "rao",
        PyCombo.pian: "pian",
        PyCombo.shuan: "shuan",
        PyCombo.ca: "ca",
        PyCombo.zuan: "zuan",
        PyCombo.chuan: "chuan",
        PyCombo.le: "le",
        PyCombo.nue: "nue",
        PyCombo.hu: "hu",
        PyCombo.nong: "nong",
        PyCombo.sang: "sang",
        PyCombo.cuo: "cuo",
        PyCombo.ya: "ya",
        PyCombo.wu: "wu",
        PyCombo.ga: "ga",
        PyCombo.zei: "zei",
        PyCombo.shang: "shang",
        PyCombo.ye: "ye",
        PyCombo.zong: "zong",
        PyCombo.jie: "jie",
        PyCombo.dou: "dou",
        PyCombo.ni: "ni",
        PyCombo.yi: "yi",
        PyCombo.zao: "zao",
        PyCombo.dan: "dan",
        PyCombo.quan: "quan",
        PyCombo.rou: "rou",
        PyCombo.yu: "yu",
        PyCombo.chui: "chui",
        YunMu.er: "er",
        PyCombo.meng: "meng",
        PyCombo.den: "den",
        PyCombo.diu: "diu",
        PyCombo.lao: "lao",
        PyCombo.qiu: "qiu",
        PyCombo.biao: "biao",
        PyCombo.tao: "tao",
        YunMu.ao: "ao",
        PyCombo.za: "za",
        PyCombo.chang: "chang",
        PyCombo.fong: "fong",
        PyCombo.bang: "bang",
        PyCombo.hong: "hong",
        PyCombo.chuo: "chuo",
        PyCombo.fou: "fou",
        PyCombo.zeng: "zeng",
        PyCombo.rui: "rui",
        PyCombo.mang: "mang",
        PyCombo.hei: "hei",
        YunMu.an: "an",
        PyCombo.gui: "gui",
        PyCombo.hao: "hao",
        PyCombo.lie: "lie",
        PyCombo.neng: "neng",
        PyCombo.liu: "liu",
        PyCombo.peng: "peng",
        PyCombo.jia: "jia",
        PyCombo.zun: "zun",
        PyCombo.bian: "bian",
        PyCombo.miu: "miu",
        PyCombo.sei: "sei",
        PyCombo.jiao: "jiao",
        PyCombo.chan: "chan",
        YunMu.ang: "ang",
        PyCombo.cen: "cen",
        PyCombo.kan: "kan",
        PyCombo.mi: "mi",
        PyCombo.kou: "kou",
        YunMu.ai: "ai",
        PyCombo.ling: "ling",
        PyCombo.zhen: "zhen",
        PyCombo.sai: "sai",
        PyCombo.ning: "ning",
        PyCombo.diao: "diao",
        PyCombo.fu: "fu",
        PyCombo.chou: "chou",
        PyCombo.qian: "qian",
        PyCombo.ma: "ma",
        PyCombo.de: "de",
        PyCombo.zhou: "zhou",
        PyCombo.tuo: "tuo",
        PyCombo.kuo: "kuo",
        PyCombo.min: "min",
        PyCombo.tai: "tai",
        PyCombo.feng: "feng",
        PyCombo.ze: "ze",
        PyCombo.zhuo: "zhuo",
        PyCombo.dun: "dun",
        PyCombo.jiang: "jiang",
        PyCombo.zhao: "zhao",
        PyCombo.zhi: "zhi",
        PyCombo.lu: "lu",
        PyCombo.yue: "yue",
        PyCombo.qun: "qun",
        PyCombo.jiu: "jiu",
        PyCombo.weng: "weng",
        PyCombo.xiong: "xiong",
        PyCombo.kao: "kao",
        PyCombo.luan: "luan",
        PyCombo.huan: "huan",
        PyCombo.zang: "zang",
        PyCombo.long: "long",
        PyCombo.tui: "tui",
        PyCombo.lan: "lan",
        PyCombo.sen: "sen",
        PyCombo.suan: "suan",
        PyCombo.pang: "pang",
        PyCombo.jian: "jian",
        PyCombo.zhe: "zhe",
        PyCombo.zhong: "zhong",
        PyCombo.ding: "ding",
        PyCombo.kai: "kai",
        PyCombo.zhua: "zhua",
        PyCombo.nan: "nan",
        PyCombo.lin: "lin",
        PyCombo.keng: "keng",
        PyCombo.sui: "sui",
        PyCombo.zhuai: "zhuai",
        PyCombo.hun: "hun",
        PyCombo.dian: "dian",
        PyCombo.wai: "wai",
        PyCombo.ming: "ming",
        PyCombo.bie: "bie",
        PyCombo.xue: "xue",
        PyCombo.hua: "hua",
        PyCombo.tiao: "tiao",
        PyCombo.qi: "qi",
        PyCombo.ba: "ba",
        PyCombo.chi: "chi",
        PyCombo.huang: "huang",
        PyCombo.cuan: "cuan",
        YunMu.a: "a",
        PyCombo.zen: "zen",
        PyCombo.fa: "fa",
        PyCombo.ce: "ce",
        PyCombo.sha: "sha",
        PyCombo.cheng: "cheng",
        PyCombo.jun: "jun",
        PyCombo.ruo: "ruo",
        PyCombo.zan: "zan",
        PyCombo.xun: "xun",
        PyCombo.dei: "dei",
        PyCombo.rong: "rong",
        PyCombo.shun: "shun",
        PyCombo.da: "da",
        PyCombo.luo: "luo",
        PyCombo.shua: "shua",
        PyCombo.pou: "pou",
        PyCombo.pie: "pie",
        PyCombo.gong: "gong",
        PyCombo.juan: "juan",
        PyCombo.yang: "yang",
        PyCombo.kuang: "kuang",
        PyCombo.ruan: "ruan",
        PyCombo.nai: "nai",
        PyCombo.zou: "zou",
        PyCombo.you: "you",
        PyCombo.gai: "gai",
        PyCombo.lang: "lang",
        PyCombo.ha: "ha",
        PyCombo.ren: "ren",
        PyCombo.mao: "mao",
        PyCombo.hai: "hai",
        PyCombo.mu: "mu",
        PyCombo.wang: "wang",
        PyCombo.re: "re",
        PyCombo.she: "she",
        PyCombo.zuo: "zuo",
        PyCombo.ken: "ken",
        PyCombo.chao: "chao",
        PyCombo.zui: "zui",
        PyCombo.chuai: "chuai",
        PyCombo.sa: "sa",
        PyCombo.cao: "cao",
        PyCombo.cha: "cha",
        PyCombo.dao: "dao",
        PyCombo.man: "man",
        PyCombo.kuan: "kuan",
        PyCombo.shi: "shi",
        PyCombo.chu: "chu",
        YunMu.e: "e",
        PyCombo.ban: "ban",
        PyCombo.ci: "ci",
        PyCombo.qia: "qia",
        PyCombo.sao: "sao",
        PyCombo.kuai: "kuai",
        PyCombo.mai: "mai",
        PyCombo.tan: "tan",
        PyCombo.shuang: "shuang",
        PyCombo.pi: "pi",
        PyCombo.ju: "ju",
        PyCombo.nen: "nen",
        PyCombo.hui: "hui",
        PyCombo.gua: "gua",
        PyCombo.ta: "ta",
        PyCombo.miao: "miao",
        PyCombo.gao: "gao",
        PyCombo.qiang: "qiang",
        PyCombo.gu: "gu",
        PyCombo.ji: "ji",
        PyCombo.du: "du",
        PyCombo.guang: "guang",
        PyCombo.pan: "pan",
        PyCombo.fiao: "fiao",
        PyCombo.mian: "mian",
        PyCombo.reng: "reng",
        PyCombo.huai: "huai",
        PyCombo.ge: "ge",
        PyCombo.wen: "wen",
        PyCombo.nu: "nu",
        PyCombo.pai: "pai",
        PyCombo.zi: "zi",
        PyCombo.nin: "nin",
        PyCombo.ben: "ben",
        PyCombo.song: "song",
        PyCombo.gan: "gan",
        PyCombo.bao: "bao",
        PyCombo.xuan: "xuan",
        PyCombo.chen: "chen",
        PyCombo.jiong: "jiong",
        PyCombo.zu: "zu",
        PyCombo.tang: "tang",
        PyCombo.bei: "bei",
        PyCombo.jing: "jing",
        PyCombo.xi: "xi",
        PyCombo.ceng: "ceng",
        PyCombo.rang: "rang",
        PyCombo.niang: "niang",
        PyCombo.shao: "shao",
        PyCombo.wo: "wo",
        PyCombo.xie: "xie",
        PyCombo.qiong: "qiong",
        PyCombo.heng: "heng",
        PyCombo.dang: "dang",
        PyCombo.lo: "lo",
        YunMu.o: "o",
        ShengMu.b: "b",
        ShengMu.p: "p",
        ShengMu.m: "m",
        ShengMu.f: "f",
        ShengMu.d: "d",
        ShengMu.t: "t",
        ShengMu.n: "n",
        ShengMu.l: "l",
        ShengMu.g: "g",
        ShengMu.k: "k",
        ShengMu.h: "h",
        ShengMu.j: "j",
        ShengMu.q: "q",
        ShengMu.x: "x",
        ShengMu.zh: "zh",
        ShengMu.ch: "ch",
        ShengMu.sh: "sh",
        ShengMu.r: "r",
        ShengMu.w: "w",
        ShengMu.y: "y",
        ShengMu.z: "z",
        ShengMu.c: "c",
        ShengMu.s: "s",
        ]
    fileprivate static let s2i_dict:[String:Py] = [
        "kei": PyCombo.kei,
        "zhang": PyCombo.zhang,
        "guan": PyCombo.guan,
        "ei": YunMu.ei,
        "guo": PyCombo.guo,
        "nei": PyCombo.nei,
        "zha": PyCombo.zha,
        "hen": PyCombo.hen,
        "chuang": PyCombo.chuang,
        "fen": PyCombo.fen,
        "pao": PyCombo.pao,
        "geng": PyCombo.geng,
        "xin": PyCombo.xin,
        "nang": PyCombo.nang,
        "fang": PyCombo.fang,
        "yao": PyCombo.yao,
        "ran": PyCombo.ran,
        "tong": PyCombo.tong,
        "seng": PyCombo.seng,
        "nao": PyCombo.nao,
        "teng": PyCombo.teng,
        "nie": PyCombo.nie,
        "te": PyCombo.te,
        "nou": PyCombo.nou,
        "run": PyCombo.run,
        "dui": PyCombo.dui,
        "die": PyCombo.die,
        "ne": PyCombo.ne,
        "pu": PyCombo.pu,
        "bai": PyCombo.bai,
        "pen": PyCombo.pen,
        "qu": PyCombo.qu,
        "cun": PyCombo.cun,
        "shen": PyCombo.shen,
        "tie": PyCombo.tie,
        "bo": PyCombo.bo,
        "liao": PyCombo.liao,
        "tun": PyCombo.tun,
        "zhan": PyCombo.zhan,
        "cui": PyCombo.cui,
        "zhun": PyCombo.zhun,
        "en": YunMu.en,
        "mie": PyCombo.mie,
        "zai": PyCombo.zai,
        "rua": PyCombo.rua,
        "cang": PyCombo.cang,
        "shan": PyCombo.shan,
        "kun": PyCombo.kun,
        "bing": PyCombo.bing,
        "lian": PyCombo.lian,
        "bin": PyCombo.bin,
        "sou": PyCombo.sou,
        "tei": PyCombo.tei,
        "di": PyCombo.di,
        "shai": PyCombo.shai,
        "deng": PyCombo.deng,
        "eng": YunMu.eng,
        "shuai": PyCombo.shuai,
        "pei": PyCombo.pei,
        "wa": PyCombo.wa,
        "shui": PyCombo.shui,
        "li": PyCombo.li,
        "duan": PyCombo.duan,
        "dai": PyCombo.dai,
        "gen": PyCombo.gen,
        "suo": PyCombo.suo,
        "mei": PyCombo.mei,
        "san": PyCombo.san,
        "su": PyCombo.su,
        "pin": PyCombo.pin,
        "zhuang": PyCombo.zhuang,
        "fan": PyCombo.fan,
        "cong": PyCombo.cong,
        "huo": PyCombo.huo,
        "ru": PyCombo.ru,
        "hou": PyCombo.hou,
        "ku": PyCombo.ku,
        "men": PyCombo.men,
        "lei": PyCombo.lei,
        "ka": PyCombo.ka,
        "qie": PyCombo.qie,
        "yo": PyCombo.yo,
        "zheng": PyCombo.zheng,
        "kong": PyCombo.kong,
        "che": PyCombo.che,
        "gang": PyCombo.gang,
        "yin": PyCombo.yin,
        "zhui": PyCombo.zhui,
        "chun": PyCombo.chun,
        "kui": PyCombo.kui,
        "lia": PyCombo.lia,
        "se": PyCombo.se,
        "yuan": PyCombo.yuan,
        "ting": PyCombo.ting,
        "fo": PyCombo.fo,
        "he": PyCombo.he,
        "jin": PyCombo.jin,
        "ying": PyCombo.ying,
        "fei": PyCombo.fei,
        "mo": PyCombo.mo,
        "wan": PyCombo.wan,
        "na": PyCombo.na,
        "nuan": PyCombo.nuan,
        "chai": PyCombo.chai,
        "la": PyCombo.la,
        "sheng": PyCombo.sheng,
        "cu": PyCombo.cu,
        "hang": PyCombo.hang,
        "shuo": PyCombo.shuo,
        "niao": PyCombo.niao,
        "qiao": PyCombo.qiao,
        "jue": PyCombo.jue,
        "shu": PyCombo.shu,
        "si": PyCombo.si,
        "gou": PyCombo.gou,
        "beng": PyCombo.beng,
        "zhai": PyCombo.zhai,
        "me": PyCombo.me,
        "xu": PyCombo.xu,
        "pa": PyCombo.pa,
        "sun": PyCombo.sun,
        "zhu": PyCombo.zhu,
        "lun": PyCombo.lun,
        "gei": PyCombo.gei,
        "xian": PyCombo.xian,
        "xiu": PyCombo.xiu,
        "que": PyCombo.que,
        "niu": PyCombo.niu,
        "kua": PyCombo.kua,
        "can": PyCombo.can,
        "chong": PyCombo.chong,
        "ti": PyCombo.ti,
        "yong": PyCombo.yong,
        "zhuan": PyCombo.zhuan,
        "piao": PyCombo.piao,
        "cou": PyCombo.cou,
        "xia": PyCombo.xia,
        "nun": PyCombo.nun,
        "ke": PyCombo.ke,
        "ping": PyCombo.ping,
        "kang": PyCombo.kang,
        "bi": PyCombo.bi,
        "tuan": PyCombo.tuan,
        "chua": PyCombo.chua,
        "wei": PyCombo.wei,
        "xiang": PyCombo.xiang,
        "nuo": PyCombo.nuo,
        "shou": PyCombo.shou,
        "shei": PyCombo.shei,
        "bu": PyCombo.bu,
        "ou": YunMu.ou,
        "leng": PyCombo.leng,
        "gun": PyCombo.gun,
        "po": PyCombo.po,
        "lue": PyCombo.lue,
        "yan": PyCombo.yan,
        "duo": PyCombo.duo,
        "yun": PyCombo.yun,
        "mou": PyCombo.mou,
        "xing": PyCombo.xing,
        "xiao": PyCombo.xiao,
        "han": PyCombo.han,
        "lou": PyCombo.lou,
        "cai": PyCombo.cai,
        "nian": PyCombo.nian,
        "qin": PyCombo.qin,
        "tou": PyCombo.tou,
        "dong": PyCombo.dong,
        "lai": PyCombo.lai,
        "liang": PyCombo.liang,
        "ri": PyCombo.ri,
        "guai": PyCombo.guai,
        "nv": PyCombo.nv,
        "dia": PyCombo.dia,
        "lv": PyCombo.lv,
        "tu": PyCombo.tu,
        "tian": PyCombo.tian,
        "qing": PyCombo.qing,
        "rao": PyCombo.rao,
        "pian": PyCombo.pian,
        "shuan": PyCombo.shuan,
        "ca": PyCombo.ca,
        "zuan": PyCombo.zuan,
        "chuan": PyCombo.chuan,
        "le": PyCombo.le,
        "nue": PyCombo.nue,
        "hu": PyCombo.hu,
        "nong": PyCombo.nong,
        "sang": PyCombo.sang,
        "cuo": PyCombo.cuo,
        "ya": PyCombo.ya,
        "wu": PyCombo.wu,
        "ga": PyCombo.ga,
        "zei": PyCombo.zei,
        "shang": PyCombo.shang,
        "ye": PyCombo.ye,
        "zong": PyCombo.zong,
        "jie": PyCombo.jie,
        "dou": PyCombo.dou,
        "ni": PyCombo.ni,
        "yi": PyCombo.yi,
        "zao": PyCombo.zao,
        "dan": PyCombo.dan,
        "quan": PyCombo.quan,
        "rou": PyCombo.rou,
        "yu": PyCombo.yu,
        "chui": PyCombo.chui,
        "er": YunMu.er,
        "meng": PyCombo.meng,
        "den": PyCombo.den,
        "diu": PyCombo.diu,
        "lao": PyCombo.lao,
        "qiu": PyCombo.qiu,
        "biao": PyCombo.biao,
        "tao": PyCombo.tao,
        "ao": YunMu.ao,
        "za": PyCombo.za,
        "chang": PyCombo.chang,
        "fong": PyCombo.fong,
        "bang": PyCombo.bang,
        "hong": PyCombo.hong,
        "chuo": PyCombo.chuo,
        "fou": PyCombo.fou,
        "zeng": PyCombo.zeng,
        "rui": PyCombo.rui,
        "mang": PyCombo.mang,
        "hei": PyCombo.hei,
        "an": YunMu.an,
        "gui": PyCombo.gui,
        "hao": PyCombo.hao,
        "lie": PyCombo.lie,
        "neng": PyCombo.neng,
        "liu": PyCombo.liu,
        "peng": PyCombo.peng,
        "jia": PyCombo.jia,
        "zun": PyCombo.zun,
        "bian": PyCombo.bian,
        "miu": PyCombo.miu,
        "sei": PyCombo.sei,
        "jiao": PyCombo.jiao,
        "chan": PyCombo.chan,
        "ang": YunMu.ang,
        "cen": PyCombo.cen,
        "kan": PyCombo.kan,
        "mi": PyCombo.mi,
        "kou": PyCombo.kou,
        "ai": YunMu.ai,
        "ling": PyCombo.ling,
        "zhen": PyCombo.zhen,
        "sai": PyCombo.sai,
        "ning": PyCombo.ning,
        "diao": PyCombo.diao,
        "fu": PyCombo.fu,
        "chou": PyCombo.chou,
        "qian": PyCombo.qian,
        "ma": PyCombo.ma,
        "de": PyCombo.de,
        "zhou": PyCombo.zhou,
        "tuo": PyCombo.tuo,
        "kuo": PyCombo.kuo,
        "min": PyCombo.min,
        "tai": PyCombo.tai,
        "feng": PyCombo.feng,
        "ze": PyCombo.ze,
        "zhuo": PyCombo.zhuo,
        "dun": PyCombo.dun,
        "jiang": PyCombo.jiang,
        "zhao": PyCombo.zhao,
        "zhi": PyCombo.zhi,
        "lu": PyCombo.lu,
        "yue": PyCombo.yue,
        "qun": PyCombo.qun,
        "jiu": PyCombo.jiu,
        "weng": PyCombo.weng,
        "xiong": PyCombo.xiong,
        "kao": PyCombo.kao,
        "luan": PyCombo.luan,
        "huan": PyCombo.huan,
        "zang": PyCombo.zang,
        "long": PyCombo.long,
        "tui": PyCombo.tui,
        "lan": PyCombo.lan,
        "sen": PyCombo.sen,
        "suan": PyCombo.suan,
        "pang": PyCombo.pang,
        "jian": PyCombo.jian,
        "zhe": PyCombo.zhe,
        "zhong": PyCombo.zhong,
        "ding": PyCombo.ding,
        "kai": PyCombo.kai,
        "zhua": PyCombo.zhua,
        "nan": PyCombo.nan,
        "lin": PyCombo.lin,
        "keng": PyCombo.keng,
        "sui": PyCombo.sui,
        "zhuai": PyCombo.zhuai,
        "hun": PyCombo.hun,
        "dian": PyCombo.dian,
        "wai": PyCombo.wai,
        "ming": PyCombo.ming,
        "bie": PyCombo.bie,
        "xue": PyCombo.xue,
        "hua": PyCombo.hua,
        "tiao": PyCombo.tiao,
        "qi": PyCombo.qi,
        "ba": PyCombo.ba,
        "chi": PyCombo.chi,
        "huang": PyCombo.huang,
        "cuan": PyCombo.cuan,
        "a": YunMu.a,
        "zen": PyCombo.zen,
        "fa": PyCombo.fa,
        "ce": PyCombo.ce,
        "sha": PyCombo.sha,
        "cheng": PyCombo.cheng,
        "jun": PyCombo.jun,
        "ruo": PyCombo.ruo,
        "zan": PyCombo.zan,
        "xun": PyCombo.xun,
        "dei": PyCombo.dei,
        "rong": PyCombo.rong,
        "shun": PyCombo.shun,
        "da": PyCombo.da,
        "luo": PyCombo.luo,
        "shua": PyCombo.shua,
        "pou": PyCombo.pou,
        "pie": PyCombo.pie,
        "gong": PyCombo.gong,
        "juan": PyCombo.juan,
        "yang": PyCombo.yang,
        "kuang": PyCombo.kuang,
        "ruan": PyCombo.ruan,
        "nai": PyCombo.nai,
        "zou": PyCombo.zou,
        "you": PyCombo.you,
        "gai": PyCombo.gai,
        "lang": PyCombo.lang,
        "ha": PyCombo.ha,
        "ren": PyCombo.ren,
        "mao": PyCombo.mao,
        "hai": PyCombo.hai,
        "mu": PyCombo.mu,
        "wang": PyCombo.wang,
        "re": PyCombo.re,
        "she": PyCombo.she,
        "zuo": PyCombo.zuo,
        "ken": PyCombo.ken,
        "chao": PyCombo.chao,
        "zui": PyCombo.zui,
        "chuai": PyCombo.chuai,
        "sa": PyCombo.sa,
        "cao": PyCombo.cao,
        "cha": PyCombo.cha,
        "dao": PyCombo.dao,
        "man": PyCombo.man,
        "kuan": PyCombo.kuan,
        "shi": PyCombo.shi,
        "chu": PyCombo.chu,
        "e": YunMu.e,
        "ban": PyCombo.ban,
        "ci": PyCombo.ci,
        "qia": PyCombo.qia,
        "sao": PyCombo.sao,
        "kuai": PyCombo.kuai,
        "mai": PyCombo.mai,
        "tan": PyCombo.tan,
        "shuang": PyCombo.shuang,
        "pi": PyCombo.pi,
        "ju": PyCombo.ju,
        "nen": PyCombo.nen,
        "hui": PyCombo.hui,
        "gua": PyCombo.gua,
        "ta": PyCombo.ta,
        "miao": PyCombo.miao,
        "gao": PyCombo.gao,
        "qiang": PyCombo.qiang,
        "gu": PyCombo.gu,
        "ji": PyCombo.ji,
        "du": PyCombo.du,
        "guang": PyCombo.guang,
        "pan": PyCombo.pan,
        "fiao": PyCombo.fiao,
        "mian": PyCombo.mian,
        "reng": PyCombo.reng,
        "huai": PyCombo.huai,
        "ge": PyCombo.ge,
        "wen": PyCombo.wen,
        "nu": PyCombo.nu,
        "pai": PyCombo.pai,
        "zi": PyCombo.zi,
        "nin": PyCombo.nin,
        "ben": PyCombo.ben,
        "song": PyCombo.song,
        "gan": PyCombo.gan,
        "bao": PyCombo.bao,
        "xuan": PyCombo.xuan,
        "chen": PyCombo.chen,
        "jiong": PyCombo.jiong,
        "zu": PyCombo.zu,
        "tang": PyCombo.tang,
        "bei": PyCombo.bei,
        "jing": PyCombo.jing,
        "xi": PyCombo.xi,
        "ceng": PyCombo.ceng,
        "rang": PyCombo.rang,
        "niang": PyCombo.niang,
        "shao": PyCombo.shao,
        "wo": PyCombo.wo,
        "xie": PyCombo.xie,
        "qiong": PyCombo.qiong,
        "heng": PyCombo.heng,
        "dang": PyCombo.dang,
        "lo": PyCombo.lo,
        "jv": PyCombo.ju,
        "xv": PyCombo.xu,
        "qv": PyCombo.qu,
        "o": YunMu.o,
        "b": ShengMu.b,
        "p": ShengMu.p,
        "m": ShengMu.m,
        "f": ShengMu.f,
        "d": ShengMu.d,
        "t": ShengMu.t,
        "n": ShengMu.n,
        "l": ShengMu.l,
        "g": ShengMu.g,
        "k": ShengMu.k,
        "h": ShengMu.h,
        "j": ShengMu.j,
        "q": ShengMu.q,
        "x": ShengMu.x,
        "zh": ShengMu.zh,
        "ch": ShengMu.ch,
        "sh": ShengMu.sh,
        "r": ShengMu.r,
        "w": ShengMu.w,
        "y": ShengMu.y,
        "z": ShengMu.z,
        "c": ShengMu.c,
        "s": ShengMu.s,
        
        "jve": PyCombo.jue,
        "qve": PyCombo.que,
        "lve": PyCombo.lue,
        "nve": PyCombo.nue,
        "yve": PyCombo.yue,
        "xve": PyCombo.xue,
        ]
    fileprivate static let shengMuSet:[Py:Int] = [
        ShengMu.b: 0,
        ShengMu.p: 0,
        ShengMu.m: 0,
        ShengMu.f: 0,
        ShengMu.d: 0,
        ShengMu.t: 0,
        ShengMu.n: 0,
        ShengMu.l: 0,
        ShengMu.g: 0,
        ShengMu.k: 0,
        ShengMu.h: 0,
        ShengMu.j: 0,
        ShengMu.q: 0,
        ShengMu.x: 0,
        ShengMu.zh: 0,
        ShengMu.ch: 0,
        ShengMu.sh: 0,
        ShengMu.r: 0,
        ShengMu.w: 0,
        ShengMu.y: 0,
        ShengMu.z: 0,
        ShengMu.c: 0,
        ShengMu.s: 0,
        ]
    fileprivate static let yunMuSet:[Py:Int] = [
        YunMu.ai:0,
        YunMu.ei:0,
        YunMu.ui:0,
        YunMu.ao:0,
        YunMu.ou:0,
        YunMu.iu:0,
        YunMu.ie:0,
        YunMu.ue:0,
        YunMu.er:0,
        YunMu.an:0,
        YunMu.en:0,
        YunMu.in:0,
        YunMu.un:0,
        YunMu.ang:0,
        YunMu.eng:0,
        YunMu.ing:0,
        YunMu.ong:0,
        YunMu.ua:0,
        YunMu.uai:0,
        YunMu.uan:0,
        YunMu.uang:0,
        YunMu.iang:0,
        YunMu.iong:0,
        YunMu.iao:0,
        YunMu.ian:0,
        YunMu.uo:0,
        YunMu.ia:0,
        YunMu.a:0,
        YunMu.o:0,
        YunMu.e:0,
        YunMu.i:0,
        YunMu.u:0,
        YunMu.v:0,
        ]
    fileprivate static let yunMu_s2i:[String:Int]  = [
        "ai" : YunMu.ai,
        "ei" : YunMu.ei,
        "ui" : YunMu.ui,
        "ao" : YunMu.ao,
        "ou" : YunMu.ou,
        "iu" : YunMu.iu,
        "ie" : YunMu.ie,
        "ue" : YunMu.ue,
        "er" : YunMu.er,
        "an" : YunMu.an,
        "en" : YunMu.en,
        "in" : YunMu.in,
        "un" : YunMu.un,
        "ang" : YunMu.ang,
        "eng" : YunMu.eng,
        "ing" : YunMu.ing,
        "ong" : YunMu.ong,
        "ua" : YunMu.ua,
        "uai" : YunMu.uai,
        "uan" : YunMu.uan,
        "uang" : YunMu.uang,
        "iang" : YunMu.iang,
        "iong" : YunMu.iong,
        "iao" : YunMu.iao,
        "ian" : YunMu.ian,
        "uo" : YunMu.uo,
        "ia" : YunMu.ia,
        "a" : YunMu.a,
        "o" : YunMu.o,
        "e" : YunMu.e,
        "i" : YunMu.i,
        "u" : YunMu.u,
        "v" : YunMu.v,
        
        "ve" : YunMu.ue,
        ]
    
    public class func pinyin2iList(from syllables:[String]) -> PyList {
        var result:PyList = []
        for ele in syllables{
            let s:Py = s2i_dict[ele] ?? 0
            let r = [s]
            result.append(r)
        }
        return result
    }
    public class func pyList2i(from pylist:[[String]]) ->PyList {
        var result:PyList = []
        for row in pylist {
            let s = row.map { return s2i_dict[$0] ?? 0 }
            result.append(s)
        }
        return result
    }

    //
    public class func pyList2s(from pylist:PyList) ->[[String]] {
        var result:[[String]] = []
        for row in pylist {
            let s = row.map { return i2s_dict[$0] ?? "" }
            result.append(s)
        }
        return result
    }
    
    public class func i2s(from py:Py) -> String{
        return i2s_dict[py] ?? ""
    }
    
    public class func isYunMu(_ py:Py) ->Bool {
        return yunMuSet[py] != nil
    }
    public class func isShengMu(_ py:Py) ->Bool {
        return shengMuSet[py] != nil
    }
    public class func getYunMu(from py:Py)->Py {
        return py & kYunMuMask
    }
    public class func getShengMu(from py:Py) ->Py {
        return py & ~kYunMuMask
    }
    
    public class func getShengMuRange(from py:Py) ->(max:Int,min:Int) {
        let shengMu = getShengMu(from: py)
        switch shengMu {
        case ShengMu.zh,ShengMu.ch,ShengMu.sh:
            return (py|kYunMuMask,shengMu)
        default:
            return (py | 0b11111111,py | 0b00000000)
        }
    }
}
extension PyString {
    public class func yunMuCode(from py:String) ->Py? {
        return yunMu_s2i[py]
    }
    public class func pyCode(from py:String) ->Py? {
        return s2i_dict[py]
    }
    public class func pyString(from py:Py) ->String? {
        return i2s_dict[py]
    }
    public class func isShengMu(from py:String) ->Bool{
        if let p = pyCode(from: py) {
            return isShengMu(p)
        }
        return false
    }
    public class func isValidPinyin(for py:Py)->Bool {
        return i2s_dict[py] != nil
    }
    public class func isValidPinyin(for py:String)->Bool {
        return s2i_dict[py] != nil
    }
}
