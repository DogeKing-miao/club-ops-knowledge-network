// ============================================================
// 社团运营知识网络 · 实体数据（只建点，不含关系）
// 共 34 个实体 / 11 类对象；全部虚构
// 用法：整段粘进 Neo4j Browser，Ctrl+Enter 运行；可重复执行（MERGE）
// 自检：MATCH (n) RETURN count(n);   // 应为 34
// ============================================================

// ---------- 社团 Club（3）----------
UNWIND [
  {id: 'C01', name: '星野天文社', attrs: '类别：学术科技；成立：2021-03-12；指导老师：郭明远'},
  {id: 'C02', name: '青蓝辩论社', attrs: '类别：人文社科；成立：2019-09-08；指导老师：沈一楠'},
  {id: 'C03', name: '拾光摄影社', attrs: '类别：文化艺术；成立：2020-05-20；社长：吴桐'}
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
] AS row
MERGE (s:Student {studentId: row.id})
SET s.studentId = row.id, s.name = row.name, s.note = row.attrs

// ---------- 部门 Department（3）----------
UNWIND [
  {id: 'D01', name: '观测部', attrs: '归属：星野天文社；职能：活动观测执行'},
  {id: 'D02', name: '宣传部', attrs: '归属：星野天文社；职能：海报与推文'},
  {id: 'D03', name: '赛事部', attrs: '归属：青蓝辩论社；职能：赛事组织'}
] AS row
MERGE (d:Department {deptId: row.id})
SET d.deptId = row.id, d.name = row.name, d.note = row.attrs

// ---------- 指导老师 Teacher（2）----------
UNWIND [
  {id: 'T01', name: '郭明远', attrs: '天文系；指导星野天文社'},
  {id: 'T02', name: '沈一楠', attrs: '哲学系；指导青蓝辩论社'}
] AS row
MERGE (t:Teacher {teacherId: row.id})
SET t.teacherId = row.id, t.name = row.name, t.note = row.attrs

// ---------- 活动 Activity（4）----------
UNWIND [
  {id: 'A01', name: '秋季观星夜', attrs: '2025-10-18 · 东区操场 · 名额 40 · 已报名 4 人 / 签到 2 人'},
  {id: 'A02', name: '新生辩论赛', attrs: '2025-10-25 · 图书馆报告厅 · 名额 32 · 已报名 3 人'},
  {id: 'A03', name: '校园人像外拍', attrs: '2025-10-18 · 东区操场（与 A01 同日同场地 → 冲突样例）'},
  {id: 'A04', name: '夜跑打卡周', attrs: '2025-11-10 · 东区操场 · 名额 60 · 已报名 3 人'}
] AS row
MERGE (a:Activity {activityId: row.id})
SET a.activityId = row.id, a.name = row.name, a.note = row.attrs

// ---------- 场地 Venue（3）----------
UNWIND [
  {id: 'V01', name: '东区操场', attrs: '容量 200 · 东区'},
  {id: 'V02', name: '学生活动中心 302', attrs: '容量 40 · 学生活动中心'},
  {id: 'V03', name: '图书馆报告厅', attrs: '容量 120 · 图书馆'}
] AS row
MERGE (v:Venue {venueId: row.id})
SET v.venueId = row.id, v.name = row.name, v.note = row.attrs

// ---------- 兴趣标签 InterestTag（4）----------
UNWIND [
  {id: 'G01', name: '天文观测', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G02', name: '摄影', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G03', name: '辩论', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G04', name: '长跑', attrs: '用于兴趣匹配与社团标签'}
] AS row
MERGE (g:InterestTag {tagId: row.id})
SET g.tagId = row.id, g.name = row.name, g.note = row.attrs

// ---------- 招新计划 Recruitment（2）----------
UNWIND [
  {id: 'R01', name: '星野天文社 2025 秋季招新', attrs: '名额 15 · 状态：进行中 · 2 人已报名未转正'},
  {id: 'R02', name: '拾光摄影社 2025 秋季招新', attrs: '名额 10 · 状态：进行中'}
] AS row
MERGE (r:Recruitment {recruitId: row.id})
SET r.recruitId = row.id, r.name = row.name, r.note = row.attrs

// ---------- 通知 Notice（2）----------
UNWIND [
  {id: 'N01', name: '秋季观星夜开始报名', attrs: '2025-10-08 发布 · 关联活动 A01'},
  {id: 'N02', name: '校园人像外拍开始报名', attrs: '2025-10-08 发布 · 关联活动 A03'}
] AS row
MERGE (n:Notice {noticeId: row.id})
SET n.noticeId = row.id, n.title = row.name, n.note = row.attrs

// ---------- 获奖 Award（2）----------
UNWIND [
  {id: 'W01', name: '省级天文知识竞赛 二等奖', attrs: '2025 年 · 归属星野天文社'},
  {id: 'W02', name: '校级辩论赛 冠军', attrs: '2025 年 · 归属青蓝辩论社'}
] AS row
MERGE (w:Award {awardId: row.id})
SET w.awardId = row.id, w.name = row.name, w.note = row.attrs

// ---------- 学期 Term（1）----------
UNWIND [
  {id: 'M01', name: '2025 秋季学期', attrs: '2025-09-01 至 2026-01-15（活动与统计的时间基准）'}
] AS row
MERGE (m:Term {termId: row.id})
SET m.termId = row.id, m.name = row.name, m.note = row.attrs

// ---------- 自检 ----------
MATCH (n) RETURN count(n) AS 实体总数;   // 应为 34
MATCH (n) RETURN labels(n)[0] AS 类型, count(*) AS 数量 ORDER BY 数量 DESC;