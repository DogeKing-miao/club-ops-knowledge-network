// ============================================================
// 05 业务动作（对应 MoSCoW【必须有】F11 / F12 +【应该有】F14）
// 用法：一个动作分三次跑 —— 先跑「1.1 执行前」截图 → 跑「1.2 执行」→ 跑「1.3 执行后」截图
// 放心：脚本可以重复跑，不会重复加人、也不会重复扣名额（用了 MERGE 与 ON CREATE）
// 想从头再演一遍：每个动作末尾都有「重置」语句，跑一下即可复原
// ============================================================

// ========== 动作一：学生加入社团（F11）==========
// 1.1 执行前：李思远还没有任何社团关系；星野天文社在册 3 人
MATCH (s:Student {studentId:'S005'})
OPTIONAL MATCH (s)-[:MEMBER_OF]->(c:Club)
RETURN s.name AS 学生, collect(c.name) AS 已加入社团, count(c) AS 社团数;

MATCH (s:Student)-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
WHERE m.status = '在册'
RETURN c.name AS 社团, count(s) AS 在册成员数;

// 1.2 执行：建立成员关系，同时把招新申请状态改为已通过
MATCH (s:Student {studentId:'S005'})-[ap:APPLIED_TO]->(:Recruitment)-[:FOR_CLUB]->(c:Club {clubId:'C01'})
MERGE (s)-[m:MEMBER_OF]->(c)
SET m.role = '成员', m.joinDate = date(), m.status = '在册', ap.status = '已通过';

// 1.3 执行后：多了一条成员关系，天文社在册成员 3 → 4
MATCH (s:Student {studentId:'S005'})-[m:MEMBER_OF]->(c:Club)
RETURN s.name AS 学生, c.name AS 社团, m.role AS 职务, m.status AS 状态;

MATCH (s:Student)-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
WHERE m.status = '在册'
RETURN c.name AS 社团, count(s) AS 在册成员数;

// ---- 重置动作一（想再演示一次、或想让关系数从 75 回到 73 时，跑这两句）----
MATCH (s:Student {studentId:'S005'})-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
DELETE m;

MATCH (s:Student {studentId:'S005'})-[ap:APPLIED_TO]->(:Recruitment)-[:FOR_CLUB]->(c:Club {clubId:'C01'})
SET ap.status = '待审核';

// ========== 动作二：学生报名活动（F12，含名额校验）==========
// 2.1 执行前：秋季观星夜 总名额 40、剩余 36、已报名 4 人
MATCH (a:Activity {activityId:'A01'})
RETURN a.name AS 活动, a.capacity AS 总名额, a.remaining AS 剩余名额, a.status AS 状态;

// 2.2 执行：写报名关系，名额 -1
//      WHERE a.remaining > 0 就是名额校验：名额为 0 时整句不会写入任何数据
//      ON CREATE 保证只有「第一次报名」才扣名额，重复跑不会越扣越少
MATCH (s:Student {studentId:'S008'}), (a:Activity {activityId:'A01'})
WHERE a.remaining > 0
MERGE (s)-[r:SIGNED_UP]->(a)
ON CREATE SET r.signedAt = datetime(), r.status = '已报名', a.remaining = a.remaining - 1;

// 2.3 执行后：报名名单多一人（郑亦航），剩余名额 36 → 35
MATCH (a:Activity {activityId:'A01'})<-[r:SIGNED_UP]-(s:Student)
RETURN a.name AS 活动, a.remaining AS 剩余名额, collect(s.name) AS 报名名单;

// ---- 重置动作二 ----
MATCH (s:Student {studentId:'S008'})-[r:SIGNED_UP]->(a:Activity {activityId:'A01'})
SET a.remaining = a.remaining + 1
DELETE r;

// ========== 动作三：成员退出（F14，改状态不删关系）==========
// 说明：郑亦航（S008）在示例数据里本来就是「已退出」，那是给 F5、F18 用的历史样例；
//       所以这个动作改用王梓涵（S004）退出拾光摄影社，才能看到真正的状态变化。
// 3.1 执行前：王梓涵在拾光摄影社，状态「在册」
MATCH (s:Student {studentId:'S004'})-[m:MEMBER_OF]->(c:Club {clubId:'C03'})
RETURN s.name AS 学生, c.name AS 社团, m.status AS 状态, m.joinDate AS 入社时间;

// 3.2 执行：状态改为已退出并记下退出时间（关系不删，历史保留）
MATCH (s:Student {studentId:'S004'})-[m:MEMBER_OF]->(c:Club {clubId:'C03'})
SET m.status = '已退出', m.quitDate = date();

// 3.3 执行后：天文社 在册 4 / 已退出 1（郑亦航）；摄影社 在册 2 / 已退出 1（王梓涵）
MATCH (s:Student)-[m:MEMBER_OF]->(c:Club)
RETURN c.name AS 社团,
       count(CASE WHEN m.status = '在册' THEN 1 END) AS 在册成员,
       count(CASE WHEN m.status = '已退出' THEN 1 END) AS 已退出
ORDER BY 社团;

// ---- 重置动作三 ----
MATCH (s:Student {studentId:'S004'})-[m:MEMBER_OF]->(c:Club {clubId:'C03'})
SET m.status = '在册'
REMOVE m.quitDate;

// ========== 动作四（可选）：活动结项 ==========
// 演示「活动从报名中 → 已结束」，配套 F13 操作结果反馈
MATCH (a:Activity {activityId:'A03'})
SET a.status = '已结束'
RETURN a.name AS 活动, a.status AS 新状态;

// ---- 重置动作四 ----
MATCH (a:Activity {activityId:'A03'})
SET a.status = '报名中';
