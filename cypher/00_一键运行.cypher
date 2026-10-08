// ============================================================
// 社团运营知识网络 · 一键运行脚本（约束 + 35 实体 + 74 关系 + 自检）
// 用法：整段复制 → 粘进 Neo4j Browser 输入框 → Ctrl+Enter
// 如果一次粘贴太卡，就按下面 4 段分开跑（每段以 ; 结尾）
// 可重复执行，不会产生重复数据（MERGE + 唯一约束）
// 共 54 条语句（原 53 条；本次 +1 条 = C04 的 TAGGED_WITH 关系）
// 版本：2026-10-07 补 C04 跑者联盟（A04 夜跑打卡周 的 HOSTS 改挂 C04、C04 加长跑标签）
//       已有旧库（34 实体 / 73 关系）的沙箱不必重跑本文件，跑 07_增量补C04.cypher 即可
//       2026-10-08 修复 CYPHER 25 报错：同一条语句里重复声明变量 row（第 2 段 11 处、第 3 段 6 处），后续块别名改为 row2…row11 / row2…row6，只改别名，数据不变
//       2026-10-08 二次修复（同一类）：同一语句里 m 先当 Term 节点变量、又当 MEMBER_OF 关系变量，CYPHER 25 报 Variable 'm' already declared → Term 变量改名 term
// ============================================================

// ---------- 第 1 段：约束（11 个唯一约束）----------
CREATE CONSTRAINT studentId_unique IF NOT EXISTS FOR (n:Student) REQUIRE n.studentId IS UNIQUE;
CREATE CONSTRAINT clubId_unique IF NOT EXISTS FOR (n:Club) REQUIRE n.clubId IS UNIQUE;
CREATE CONSTRAINT deptId_unique IF NOT EXISTS FOR (n:Department) REQUIRE n.deptId IS UNIQUE;
CREATE CONSTRAINT teacherId_unique IF NOT EXISTS FOR (n:Teacher) REQUIRE n.teacherId IS UNIQUE;
CREATE CONSTRAINT activityId_unique IF NOT EXISTS FOR (n:Activity) REQUIRE n.activityId IS UNIQUE;
CREATE CONSTRAINT venueId_unique IF NOT EXISTS FOR (n:Venue) REQUIRE n.venueId IS UNIQUE;
CREATE CONSTRAINT tagId_unique IF NOT EXISTS FOR (n:InterestTag) REQUIRE n.tagId IS UNIQUE;
CREATE CONSTRAINT recruitId_unique IF NOT EXISTS FOR (n:Recruitment) REQUIRE n.recruitId IS UNIQUE;
CREATE CONSTRAINT noticeId_unique IF NOT EXISTS FOR (n:Notice) REQUIRE n.noticeId IS UNIQUE;
CREATE CONSTRAINT awardId_unique IF NOT EXISTS FOR (n:Award) REQUIRE n.awardId IS UNIQUE;
CREATE CONSTRAINT termId_unique IF NOT EXISTS FOR (n:Term) REQUIRE n.termId IS UNIQUE;

// ---------- 第 2 段：35 个实体 ----------
UNWIND [
  {id: 'C01', name: '星野天文社', attrs: '类别：学术科技；成立：2021-03-12；指导老师：郭明远'},
  {id: 'C02', name: '青蓝辩论社', attrs: '类别：人文社科；成立：2019-09-08；指导老师：沈一楠'},
  {id: 'C03', name: '拾光摄影社', attrs: '类别：文化艺术；成立：2020-05-20；社长：吴桐'},
  {id: 'C04', name: '跑者联盟', attrs: '类别：体育健康；成立：2018-04-16；主办 A04 夜跑打卡周（成员未纳入本期 8 人样例）'}
] AS row
MERGE (c:Club {clubId: row.id})
SET c.clubId = row.id, c.name = row.name, c.note = row.attrs

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

UNWIND [
  {id: 'D01', name: '观测部', attrs: '归属：星野天文社；职能：活动观测执行'},
  {id: 'D02', name: '宣传部', attrs: '归属：星野天文社；职能：海报与推文'},
  {id: 'D03', name: '赛事部', attrs: '归属：青蓝辩论社；职能：赛事组织'}
] AS row3
MERGE (d:Department {deptId: row3.id})
SET d.deptId = row3.id, d.name = row3.name, d.note = row3.attrs

UNWIND [
  {id: 'T01', name: '郭明远', attrs: '天文系；指导星野天文社'},
  {id: 'T02', name: '沈一楠', attrs: '哲学系；指导青蓝辩论社'}
] AS row4
MERGE (t:Teacher {teacherId: row4.id})
SET t.teacherId = row4.id, t.name = row4.name, t.note = row4.attrs

UNWIND [
  {id: 'A01', name: '秋季观星夜', attrs: '2025-10-18 · 东区操场 · 名额 40 · 已报名 4 人 / 签到 2 人'},
  {id: 'A02', name: '新生辩论赛', attrs: '2025-10-25 · 图书馆报告厅 · 名额 32 · 已报名 3 人'},
  {id: 'A03', name: '校园人像外拍', attrs: '2025-10-18 · 东区操场（与 A01 同日同场地 → 冲突样例）'},
  {id: 'A04', name: '夜跑打卡周', attrs: '2025-11-10 · 东区操场 · 名额 60 · 已报名 3 人'}
] AS row5
MERGE (a:Activity {activityId: row5.id})
SET a.activityId = row5.id, a.name = row5.name, a.note = row5.attrs

UNWIND [
  {id: 'V01', name: '东区操场', attrs: '容量 200 · 东区'},
  {id: 'V02', name: '学生活动中心 302', attrs: '容量 40 · 学生活动中心'},
  {id: 'V03', name: '图书馆报告厅', attrs: '容量 120 · 图书馆'}
] AS row6
MERGE (v:Venue {venueId: row6.id})
SET v.venueId = row6.id, v.name = row6.name, v.note = row6.attrs

UNWIND [
  {id: 'G01', name: '天文观测', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G02', name: '摄影', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G03', name: '辩论', attrs: '用于兴趣匹配与社团标签'},
  {id: 'G04', name: '长跑', attrs: '用于兴趣匹配与社团标签'}
] AS row7
MERGE (g:InterestTag {tagId: row7.id})
SET g.tagId = row7.id, g.name = row7.name, g.note = row7.attrs

UNWIND [
  {id: 'R01', name: '星野天文社 2025 秋季招新', attrs: '名额 15 · 状态：进行中 · 2 人已报名未转正'},
  {id: 'R02', name: '拾光摄影社 2025 秋季招新', attrs: '名额 10 · 状态：进行中'}
] AS row8
MERGE (r:Recruitment {recruitId: row8.id})
SET r.recruitId = row8.id, r.name = row8.name, r.note = row8.attrs

UNWIND [
  {id: 'N01', name: '秋季观星夜开始报名', attrs: '2025-10-08 发布 · 关联活动 A01'},
  {id: 'N02', name: '校园人像外拍开始报名', attrs: '2025-10-08 发布 · 关联活动 A03'}
] AS row9
MERGE (n:Notice {noticeId: row9.id})
SET n.noticeId = row9.id, n.title = row9.name, n.note = row9.attrs

UNWIND [
  {id: 'W01', name: '省级天文知识竞赛 二等奖', attrs: '2025 年 · 归属星野天文社'},
  {id: 'W02', name: '校级辩论赛 冠军', attrs: '2025 年 · 归属青蓝辩论社'}
] AS row10
MERGE (w:Award {awardId: row10.id})
SET w.awardId = row10.id, w.name = row10.name, w.note = row10.attrs

UNWIND [
  {id: 'M01', name: '2025 秋季学期', attrs: '2025-09-01 至 2026-01-15（活动与统计的时间基准）'}
] AS row11
MERGE (m:Term {termId: row11.id})
SET m.termId = row11.id, m.name = row11.name, m.note = row11.attrs

MATCH (n) RETURN labels(n)[0] AS 类型, count(DISTINCT n) AS 数量 ORDER BY 数量 DESC;

// ---------- 第 3 段：属性补全 + 74 条关系 ----------
// ============================================================
// 社团运营知识网络 · 03 属性补全 + 关系数据
// 前置：先跑 01 约束与 02 实体（或直接跑 00_一键运行.cypher）
// 共 74 条关系 / 18 种关系类型；可重复执行（MERGE）
// 版本：2026-10-07 补 C04 跑者联盟（HOSTS 改挂 C04 + C04 加长跑标签）
// ============================================================

// ---------- 第一步：把关键字段从 note 里提升为真正的属性 ----------
// MATCH …
MATCH (c:Club {clubId:'C01'}) SET c.category='学术科技', c.founded=date('2021-03-12')
MATCH (c:Club {clubId:'C02'}) SET c.category='人文社科', c.founded=date('2019-09-08')
MATCH (c:Club {clubId:'C03'}) SET c.category='文化艺术', c.founded=date('2020-05-20')
// MATCH …（2026-10-07 新增：C04 跑者联盟 的类别与成立时间）
MATCH (c:Club {clubId:'C04'}) SET c.category='体育健康', c.founded=date('2018-04-16')

// UNWIND …
UNWIND [{id:'S001',grade:'2024',major:'天文学'},{id:'S002',grade:'2023',major:'物理学'},{id:'S003',grade:'2024',major:'新闻传播'},{id:'S004',grade:'2023',major:'计算机'},{id:'S005',grade:'2024',major:'哲学'},{id:'S006',grade:'2024',major:'汉语言文学'},{id:'S007',grade:'2023',major:'视觉传达'},{id:'S008',grade:'2024',major:'数学'}] AS row
MATCH (s:Student {studentId: row.id}) SET s.grade = row.grade, s.major = row.major

// UNWIND …
UNWIND [{id:'A01',d:'2025-10-18',cap:40,rem:36,st:'报名中'},{id:'A02',d:'2025-10-25',cap:32,rem:29,st:'报名中'},{id:'A03',d:'2025-10-18',cap:20,rem:18,st:'报名中'},{id:'A04',d:'2025-11-10',cap:60,rem:57,st:'报名中'}] AS row2
MATCH (a:Activity {activityId: row2.id}) SET a.date = date(row2.d), a.capacity = row2.cap, a.remaining = row2.rem, a.status = row2.st

// UNWIND …
UNWIND [{id:'V01',cap:200},{id:'V02',cap:40},{id:'V03',cap:120}] AS row3
MATCH (v:Venue {venueId: row3.id}) SET v.capacity = row3.cap

// UNWIND …
UNWIND [{id:'R01',q:15,st:'进行中'},{id:'R02',q:10,st:'进行中'}] AS row4
MATCH (r:Recruitment {recruitId: row4.id}) SET r.quota = row4.q, r.status = row4.st

// UNWIND …
UNWIND [{id:'W01',y:2025},{id:'W02',y:2025}] AS row5
MATCH (w:Award {awardId: row5.id}) SET w.year = row5.y

// MATCH …
MATCH (term:Term {termId:'M01'}) SET term.startDate = date('2025-09-01'), term.endDate = date('2026-01-15')

// ---------- 第二步：关系数据 ----------
// ===== 成员关系 MEMBER_OF（7） =====
// 学生 -[MEMBER_OF {role, joinDate, status, quitDate}]-> 社团
// S005、S006 故意没有 MEMBER_OF —— 他们是「报名了还没转正」的人（钩子 H2）
// S008 是已退出（status='已退出'），用于演示 F14 与流失分析
UNWIND [
  {s:'S001', c:'C01', role:'社长',   join:'2024-09-10', st:'在册', quit:null},
  {s:'S002', c:'C01', role:'观测部部长', join:'2024-09-12', st:'在册', quit:null},
  {s:'S003', c:'C01', role:'成员',   join:'2024-10-08', st:'在册', quit:null},
  {s:'S003', c:'C03', role:'成员',   join:'2025-03-02', st:'在册', quit:null},
  {s:'S004', c:'C03', role:'成员',   join:'2023-10-11', st:'在册', quit:null},
  {s:'S007', c:'C03', role:'社长',   join:'2023-09-05', st:'在册', quit:null},
  {s:'S008', c:'C01', role:'成员',   join:'2024-09-20', st:'已退出', quit:'2025-11-20'}
] AS row6
MATCH (s:Student {studentId: row6.s}), (c:Club {clubId: row6.c})
MERGE (s)-[m:MEMBER_OF]->(c)
SET m.role = row6.role, m.joinDate = date(row6.join), m.status = row6.st
FOREACH (_ IN CASE WHEN row6.quit IS NULL THEN [] ELSE [1] END | SET m.quitDate = date(row6.quit));

// ===== 部门归属 IN_DEPARTMENT / BELONGS_TO（4） =====
// 学生 -[:IN_DEPARTMENT]-> 部门；部门 -[:BELONGS_TO]-> 社团
MATCH (s:Student {studentId:'S002'}), (d:Department {deptId:'D01'}) MERGE (s)-[:IN_DEPARTMENT]->(d);
MATCH (d:Department {deptId:'D01'}), (c:Club {clubId:'C01'}) MERGE (d)-[:BELONGS_TO]->(c);
MATCH (d:Department {deptId:'D02'}), (c:Club {clubId:'C01'}) MERGE (d)-[:BELONGS_TO]->(c);
MATCH (d:Department {deptId:'D03'}), (c:Club {clubId:'C02'}) MERGE (d)-[:BELONGS_TO]->(c);

// ===== 指导关系 ADVISES（2） =====
MATCH (t:Teacher {teacherId:'T01'}), (c:Club {clubId:'C01'}) MERGE (t)-[:ADVISES]->(c);
MATCH (t:Teacher {teacherId:'T02'}), (c:Club {clubId:'C02'}) MERGE (t)-[:ADVISES]->(c);

// ===== 社团举办活动 HOSTS（4） =====
// A04 夜跑打卡周 由 C04 跑者联盟主办（2026-10-07 修正：原先缺社团节点，曾临时挂在 C03）
MATCH (c:Club {clubId:'C01'}), (a:Activity {activityId:'A01'}) MERGE (c)-[:HOSTS]->(a);
MATCH (c:Club {clubId:'C02'}), (a:Activity {activityId:'A02'}) MERGE (c)-[:HOSTS]->(a);
MATCH (c:Club {clubId:'C03'}), (a:Activity {activityId:'A03'}) MERGE (c)-[:HOSTS]->(a);
MATCH (c:Club {clubId:'C04'}), (a:Activity {activityId:'A04'}) MERGE (c)-[:HOSTS]->(a);

// ===== 活动场地 HELD_AT（4） =====
// A01 与 A03 同一天、同一场地（东区操场）→ 演示 F8 场地冲突检测（钩子 H1）
MATCH (a:Activity {activityId:'A01'}), (v:Venue {venueId:'V01'}) MERGE (a)-[:HELD_AT]->(v);
MATCH (a:Activity {activityId:'A02'}), (v:Venue {venueId:'V03'}) MERGE (a)-[:HELD_AT]->(v);
MATCH (a:Activity {activityId:'A03'}), (v:Venue {venueId:'V01'}) MERGE (a)-[:HELD_AT]->(v);
MATCH (a:Activity {activityId:'A04'}), (v:Venue {venueId:'V01'}) MERGE (a)-[:HELD_AT]->(v);

// ===== 活动报名 SIGNED_UP（12） =====
// 学生 -[SIGNED_UP {signedAt, status}]-> 活动
// A01 报名 4 人、实际签到只有 2 人 → 演示 F6「谁报名了没来」（钩子 H6）
UNWIND [
  {s:'S001', a:'A01', at:'2025-10-09T10:00:00'},
  {s:'S002', a:'A01', at:'2025-10-09T11:30:00'},
  {s:'S003', a:'A01', at:'2025-10-10T09:05:00'},
  {s:'S004', a:'A01', at:'2025-10-12T20:31:00'},
  {s:'S005', a:'A02', at:'2025-10-14T13:20:00'},
  {s:'S006', a:'A02', at:'2025-10-14T19:02:00'},
  {s:'S007', a:'A02', at:'2025-10-15T08:47:00'},
  {s:'S004', a:'A03', at:'2025-10-11T16:25:00'},
  {s:'S007', a:'A03', at:'2025-10-13T12:09:00'},
  {s:'S004', a:'A04', at:'2025-11-02T21:15:00'},
  {s:'S007', a:'A04', at:'2025-11-03T07:38:00'},
  {s:'S008', a:'A04', at:'2025-11-03T22:04:00'}
] AS row
MATCH (s:Student {studentId: row.s}), (a:Activity {activityId: row.a})
MERGE (s)-[r:SIGNED_UP]->(a)
SET r.signedAt = datetime(row.at), r.status = '已报名';

// ===== 活动签到 ATTENDED（6） =====
UNWIND [
  {s:'S001', a:'A01'}, {s:'S002', a:'A01'},
  {s:'S005', a:'A02'}, {s:'S006', a:'A02'},
  {s:'S004', a:'A03'}, {s:'S007', a:'A03'}
] AS row
MATCH (s:Student {studentId: row.s}), (a:Activity {activityId: row.a})
MERGE (s)-[:ATTENDED]->(a);

// ===== 兴趣标签 HAS_TAG（11） =====
// S005 兴趣含「天文观测 G01」但不在天文社 → 演示 F17 兴趣匹配推荐（钩子 H5）
UNWIND [
  {s:'S001', g:'G01'}, {s:'S002', g:'G01'}, {s:'S002', g:'G04'},
  {s:'S003', g:'G02'}, {s:'S004', g:'G02'}, {s:'S004', g:'G04'},
  {s:'S005', g:'G01'}, {s:'S005', g:'G03'},
  {s:'S006', g:'G03'}, {s:'S007', g:'G02'}, {s:'S008', g:'G04'}
] AS row
MATCH (s:Student {studentId: row.s}), (g:InterestTag {tagId: row.g})
MERGE (s)-[:HAS_TAG]->(g);

// ===== 社团标签 TAGGED_WITH（4） =====
// 每个社团挂一个标签：C01→G01、C02→G03、C03→G02、C04→G04 长跑（本次新增）
MATCH (c:Club {clubId:'C01'}), (g:InterestTag {tagId:'G01'}) MERGE (c)-[:TAGGED_WITH]->(g);
MATCH (c:Club {clubId:'C02'}), (g:InterestTag {tagId:'G03'}) MERGE (c)-[:TAGGED_WITH]->(g);
MATCH (c:Club {clubId:'C03'}), (g:InterestTag {tagId:'G02'}) MERGE (c)-[:TAGGED_WITH]->(g);
MATCH (c:Club {clubId:'C04'}), (g:InterestTag {tagId:'G04'}) MERGE (c)-[:TAGGED_WITH]->(g);

// ===== 招新报名 APPLIED_TO + FOR_CLUB（5） =====
// S005、S006 报了 R01 但尚未入社 → 演示 F9 招新转化（钩子 H2）
UNWIND [
  {s:'S005', r:'R01', st:'待审核', at:'2025-09-20'},
  {s:'S006', r:'R01', st:'待审核', at:'2025-09-21'},
  {s:'S004', r:'R02', st:'已通过', at:'2025-09-19'}
] AS row
MATCH (s:Student {studentId: row.s}), (r:Recruitment {recruitId: row.r})
MERGE (s)-[ap:APPLIED_TO]->(r)
SET ap.status = row.st, ap.submittedAt = date(row.at);
MATCH (r:Recruitment {recruitId:'R01'}), (c:Club {clubId:'C01'}) MERGE (r)-[:FOR_CLUB]->(c);
MATCH (r:Recruitment {recruitId:'R02'}), (c:Club {clubId:'C03'}) MERGE (r)-[:FOR_CLUB]->(c);

// ===== 通知发布与关联（4） =====
MATCH (c:Club {clubId:'C01'}), (n:Notice {noticeId:'N01'}) MERGE (c)-[:PUBLISHES]->(n);
MATCH (c:Club {clubId:'C03'}), (n:Notice {noticeId:'N02'}) MERGE (c)-[:PUBLISHES]->(n);
MATCH (n:Notice {noticeId:'N01'}), (a:Activity {activityId:'A01'}) MERGE (n)-[:ANNOUNCES]->(a);
MATCH (n:Notice {noticeId:'N02'}), (a:Activity {activityId:'A03'}) MERGE (n)-[:ANNOUNCES]->(a);

// ===== 获奖归属 WON + AWARDED_TO（4） =====
MATCH (s:Student {studentId:'S001'}), (w:Award {awardId:'W01'}) MERGE (s)-[:WON]->(w);
MATCH (s:Student {studentId:'S006'}), (w:Award {awardId:'W02'}) MERGE (s)-[:WON]->(w);
MATCH (w:Award {awardId:'W01'}), (c:Club {clubId:'C01'}) MERGE (w)-[:AWARDED_TO]->(c);
MATCH (w:Award {awardId:'W02'}), (c:Club {clubId:'C02'}) MERGE (w)-[:AWARDED_TO]->(c);

// ===== 活动组织与学期 IN_TERM（7） =====
MATCH (s:Student {studentId:'S001'}), (a:Activity {activityId:'A01'}) MERGE (s)-[:ORGANIZED]->(a);
MATCH (s:Student {studentId:'S006'}), (a:Activity {activityId:'A02'}) MERGE (s)-[:ORGANIZED]->(a);
MATCH (s:Student {studentId:'S007'}), (a:Activity {activityId:'A03'}) MERGE (s)-[:ORGANIZED]->(a);
UNWIND ['A01','A02','A03','A04'] AS aid
MATCH (a:Activity {activityId: aid}), (m:Term {termId:'M01'})
MERGE (a)-[:IN_TERM]->(m);

// ---------- 第 4 段：自检（截图留档）----------
MATCH (n) RETURN count(n) AS 实体总数;               // 35
MATCH ()-[r]->() RETURN count(r) AS 关系总数;        // 74
MATCH (n) RETURN labels(n)[0] AS 类型, count(*) AS 数量 ORDER BY 数量 DESC;
MATCH ()-[r]->() RETURN type(r) AS 关系类型, count(*) AS 条数 ORDER BY 条数 DESC;