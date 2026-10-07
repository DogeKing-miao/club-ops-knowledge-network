// ============================================================
// 07 重置与排错（演练跑乱了、或想让关系数回到 74 时跑这里）
// 背景：干净状态是 35 个实体 / 74 条关系。
//       （2026-10-07 补 C04 跑者联盟 之后的口径：原来 34 实体 / 73 关系，
//         新增 1 个社团节点 + 1 条 C04→G04 长跑标签关系；A04 的 HOSTS 由 C03 改挂 C04，条数不变）
//       跑完「动作一 加入社团」和「动作二 报名活动」后，关系数会变成 76 条 —— 这是正常的，
//       因为这两个动作各新建了 1 条关系，恰好证明"业务动作真的改动了数据"。
//       如果要拍「02-关系数.png」这张基线图，先跑下面的重置，回到 74 再拍。
// ============================================================

// ---------- 第一步：看现在的数量 ----------
MATCH (n) RETURN count(n) AS 实体数;          // 一直是 35（三个动作都只建关系、不建点）
MATCH ()-[r]->() RETURN count(r) AS 关系数;   // 干净 74；跑过动作一、二后是 76

// ---------- 第二步：看有没有「多出来」的关系 ----------
// 出现「李思远」这一行，说明动作一跑过（他是动作新加进天文社的）
MATCH (s:Student)-[m:MEMBER_OF]->(c:Club)
RETURN s.name AS 学生, c.name AS 社团, m.role AS 职务, m.status AS 状态, m.joinDate AS 入社时间
ORDER BY 入社时间;

// 报名名单里出现「郑亦航」、剩余名额是 35，说明动作二跑过
MATCH (a:Activity {activityId:'A01'})<-[r:SIGNED_UP]-(s:Student)
RETURN collect(s.name) AS 报名名单, a.remaining AS 剩余名额, a.capacity AS 总名额;

// ---------- 第三步：重置（需要哪段跑哪段）----------

// 重置动作一（李思远退出天文社、招新申请回到待审核）
MATCH (s:Student {studentId:'S005'})-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
DELETE m;

MATCH (s:Student {studentId:'S005'})-[ap:APPLIED_TO]->(:Recruitment)-[:FOR_CLUB]->(c:Club {clubId:'C01'})
SET ap.status = '待审核';

// 重置动作二（撤销郑亦航的报名、名额加回来）
MATCH (s:Student {studentId:'S008'})-[r:SIGNED_UP]->(a:Activity {activityId:'A01'})
SET a.remaining = a.remaining + 1
DELETE r;

// 重置动作三（王梓涵回到在册）
MATCH (s:Student {studentId:'S004'})-[m:MEMBER_OF]->(c:Club {clubId:'C03'})
SET m.status = '在册'
REMOVE m.quitDate;

// 重置动作四（活动回到报名中）
MATCH (a:Activity {activityId:'A03'})
SET a.status = '报名中';

// ---------- 第四步：确认回到基线 ----------
MATCH (n) RETURN count(n) AS 实体数;          // 35
MATCH ()-[r]->() RETURN count(r) AS 关系数;   // 74
MATCH ()-[r]->() RETURN type(r) AS 关系类型, count(*) AS 条数 ORDER BY 条数 DESC;
// 关系类型分布应为：SIGNED_UP 12、HAS_TAG 11、MEMBER_OF 7、ATTENDED 6、
//                  HOSTS 4、HELD_AT 4、IN_TERM 4、TAGGED_WITH 4（原 3，2026-10-07 +C04→G04）、
//                  BELONGS_TO 3、APPLIED_TO 3、ORGANIZED 3、ADVISES 2、FOR_CLUB 2、
//                  PUBLISHES 2、ANNOUNCES 2、WON 2、AWARDED_TO 2、IN_DEPARTMENT 1
// 合计 74 条 / 18 种类型

// 顺便确认「跑者联盟」没有丢：应看到 C04 跑者联盟 主办 A04 夜跑打卡周、且 A04 只出现一次
MATCH (c:Club)-[:HOSTS]->(a:Activity)
RETURN c.clubId AS 社团编号, c.name AS 主办社团, a.activityId AS 活动编号, a.name AS 活动
ORDER BY 活动编号;

// ---------- 第五步：万一数量对不上，看这条（谁连了谁，逐条列出来）----------
MATCH (a)-[r]->(b)
RETURN type(r) AS 关系, coalesce(a.name, a.activityId, a.clubId) AS 起点,
       coalesce(b.name, b.activityId, b.clubId) AS 终点, r.status AS 状态
ORDER BY 关系, 起点;
