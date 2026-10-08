// ============================================================
// 社团运营知识网络 · 03 属性补全 + 关系数据
// 前置：先跑 01 约束与 02 实体（或直接跑 00_一键运行.cypher）
// 共 74 条关系 / 18 种关系类型；可重复执行（MERGE）
// 版本：2026-10-07 补 C04 跑者联盟 —— A04 夜跑打卡周 的 HOSTS 由 C03 改挂 C04，
//       并给 C04 补 TAGGED_WITH → G04 长跑（原 73 条 → 74 条）
//       已有旧库的沙箱直接跑 07_增量补C04.cypher，不用重跑本文件
//       2026-10-08 修复 CYPHER 25 报错：同一条语句里重复声明变量 row，后续块别名改为 row2…row6，数据不变
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
MATCH (m:Term {termId:'M01'}) SET m.startDate = date('2025-09-01'), m.endDate = date('2026-01-15')

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
// A04 夜跑打卡周 由 C04 跑者联盟主办（2026-10-07 修正：原实体清单缺社团节点，
// 曾临时挂在 C03 拾光摄影社；现已补 C04 并把这条改挂 C04）
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
// 每个社团挂一个标签：C01→G01 天文观测、C02→G03 辩论、C03→G02 摄影、C04→G04 长跑（本次新增）
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

// ---------- 自检 ----------
MATCH (n) RETURN count(n) AS 实体总数;              // 35
MATCH ()-[r]->() RETURN count(r) AS 关系总数;        // 74
MATCH ()-[r]->() RETURN type(r) AS 关系类型, count(*) AS 条数 ORDER BY 条数 DESC;