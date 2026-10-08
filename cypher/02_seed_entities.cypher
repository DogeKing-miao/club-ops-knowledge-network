// ============================================================
// 社团运营知识网络 · 实体数据（只建点，不含关系）
// 共 35 个实体 / 11 类对象；全部虚构
// 用法：整段粘进 Neo4j Browser，Ctrl+Enter 运行；可重复执行（MERGE）
// 自检：MATCH (n) RETURN count(n);   // 应为 35
// 版本：2026-10-07 补 C04 跑者联盟（原先 A04 夜跑打卡周没有归属社团）
//       已有 34 个实体的沙箱不用重跑本文件，直接跑 07_增量补C04.cypher 即可
//       2026-10-08 修复 CYPHER 25 报错：同一条语句里重复声明变量 row，后续块别名改为 row2…row11，数据不变
// ============================================================

// ---------- 社团 Club（4）----------
UNWIND [
  {id: 'C01', name: '星野天文社', attrs: '类别：学术科技；成立：2021-03-12；指导老师：郭明远'},
  {id: 'C02', name: '青蓝辩论社', attrs: '类别：人文社科；成立：2019-09-08；指导老师：沈一楠'},
  {id: 'C03', name: '拾光摄影社', attrs: '类别：文化艺术；成立：2020-05-20；社长：吴桐'},
  {id: 'C04', name: '跑者联盟', attrs: '类别：体育健康；成立：2018-04-16；主办 A04 夜跑打卡周（成员未纳入本期 8 人样例）'}
] AS row
MERGE (c:Club {clubId: row.id})
SET c.clubId = row.id, c.name = row.name, c.note = row.attrs

// ---------- 学生 Student（8）----------
UNWIND [
  {id: 'S001', name: '林一舟', attrs: '2024 级 · 天文学 · 星野天文社社长'},
  {id: 'S002', name: '赵敏', attrs: '2023 级 · 物理学 · 观测部部长'},
  {id: 'S003', name: '陈嘉禾', attrs: '2024 级 · 新闻传播 · 同时在两个社团（跨社团样例）'},
  {id: 'S004', name: '王梓涵', attrs: '2023 级 · 计算机 · 摄影社成员 · 多场活动报名'},
  {id: 'S005', name: '李思远', attrs: '2024 级 · 哲学 · 报名天文社招新但未转正 · 兴趣含天文观测'},
  {id: 'S006', name: '周雨桐', attrs: '2024 级 · 汉语言文学 · 报名天文社招新但未转正'},
  {id: 'S007', name: '吴桐', attrs: '2023 级 · 视觉传达 · 拾光摄影社社长'},
  {id: 'S008', name: '郑亦航', attrs: '2024 级 · 数学 · 已退出天文社（退出样例）'}
] AS row2
MERGE (s:Student {studentId: row2.id})
SET s.studentId = row2.id, s.name = row2.name, s.note = row2.attrs

// ---------- 部门 Department（3）----------
UNWIND [
  {id: 'D01', name: '观测部', attrs: '归属：星野天文社；职能：活动观测执行'},
  {id: 'D02', name: '宣传部', attrs: '归属：星野天文社；职能：海报与推文'},
  {id: 'D03', name: '赛事部', attrs: '归属：青蓝辩论社；职能：赛事组织'}
] AS row3
MERGE (d:Department {deptId: row3.id})
SET d.deptId = row3.id, d.name = row3.name, d.note = row3.attrs

// ---------- 指导老师 Teacher（2）----------
UNWIND [
  {id: 'T01', name: '郭明远', attrs: '天文系；指导星野天文社'},
  {id: 'T02', name: '沈一楠', attrs: '哲学系；指导青蓝辩论社'}
] AS row4
MERGE (t:Teacher {teacherId: row4.id})
SET t.teacherId = row4.id, t.name = row4.name, t.note = row4.attrs

// ---------- 活动 Activity（4）----------
UNWIND [
  {id: 'A01', name: '秋季观星夜', attrs: '2025-10-18 · 东区操场 · 名额 40 · 已报名 4 人 / 签到 2 人'},
  {id: 'A02', name: '新生辩论赛', attrs: '2025-10-25 · 图书馆报告厅 · 名额 32 · 已报名 3 人'},
  {id: 'A03', name: '校园人像外拍', attrs: '2025-10-18 · 东区操场（与 A01 同日同场地 → 冲突样例）'},
  {id: 'A04', name: '夜跑打卡周', attrs: '2025-11-10 · 东区操场 · 名额 60 · 已报名 3 人'}
] AS row5
MERGE (a:Activity {activityId: row5.id})
SET a.activityId = row5.id, a.name = row5.name, a.note = row5.attrs

// ---------- 场地 Venue（3）----------
UNWIND [
  {id: 'V01', name: '东区操场', attrs: '容量 200 · 东区'},
  {id: 'V02', name: '学生活动中心 302', attrs: '容量 40 · 学生活动中心'},
  {id: 'V03', name: '图书馆报告厅', attrs: '容量 120 · 图书馆'}
] AS row6
MERGE (v:Venue {venueId: row6.id})
SET v.venueId = row6.id, v.name = row6.name, v.note = row6.attrs

// ---------- 兴趣标签 InterestTag（4）----------
UNWIND [
  {id: 'G01', name: '天文观测', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G02', name: '摄影', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G03', name: '辩论', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G04', name: '长跑', attrs: '用于兴趣匹配与社团标签'}
] AS row7
MERGE (g:InterestTag {tagId: row7.id})
SET g.tagId = row7.id, g.name = row7.name, g.note = row7.attrs

// ---------- 招新计划 Recruitment（2）----------
UNWIND [
  {id: 'R01', name: '星野天文社 2025 秋季招新', attrs: '名额 15 · 状态：进行中 · 2 人已报名未转正'},
  {id: 'R02', name: '拾光摄影社 2025 秋季招新', attrs: '名额 10 · 状态：进行中'}
] AS row8
MERGE (r:Recruitment {recruitId: row8.id})
SET r.recruitId = row8.id, r.name = row8.name, r.note = row8.attrs

// ---------- 通知 Notice（2）----------
UNWIND [
  {id: 'N01', name: '秋季观星夜开始报名', attrs: '2025-10-08 发布 · 关联活动 A01'},
  {id: 'N02', name: '校园人像外拍开始报名', attrs: '2025-10-08 发布 · 关联活动 A03'}
] AS row9
MERGE (n:Notice {noticeId: row9.id})
SET n.noticeId = row9.id, n.title = row9.name, n.note = row9.attrs

// ---------- 获奖 Award（2）----------
UNWIND [
  {id: 'W01', name: '省级天文知识竞赛 二等奖', attrs: '2025 年 · 归属星野天文社'},
  {id: 'W02', name: '校级辩论赛 冠军', attrs: '2025 年 · 归属青蓝辩论社'}
] AS row10
MERGE (w:Award {awardId: row10.id})
SET w.awardId = row10.id, w.name = row10.name, w.note = row10.attrs

// ---------- 学期 Term（1）----------
UNWIND [
  {id: 'M01', name: '2025 秋季学期', attrs: '2025-09-01 至 2026-01-15（活动与统计的时间基准）'}
] AS row11
MERGE (m:Term {termId: row11.id})
SET m.termId = row11.id, m.name = row11.name, m.note = row11.attrs

// ---------- 自检 ----------
MATCH (n) RETURN count(DISTINCT n) AS 实体总数;   // 应为 35（社团 4 / 学生 8 / 部门 3 / 老师 2 / 活动 4 / 场地 3 / 兴趣标签 4 / 招新 2 / 通知 2 / 获奖 2 / 学期 1）
MATCH (n) RETURN labels(n)[0] AS 类型, count(*) AS 数量 ORDER BY 数量 DESC;