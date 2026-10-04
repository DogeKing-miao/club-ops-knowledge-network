// ============================================================
// 04 查询场景（对应 MoSCoW 功能编号，逐条可截屏演示）
// 每个查询整段粘贴运行；注释里写明对应功能与预期结果
// ============================================================

// ---------- F5 社团成员名单查询 ----------
// 预期：星野天文社 3 名在册成员（林一舟/赵敏/陈嘉禾），郑亦航 状态为已退出
MATCH (s:Student)-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
RETURN s.name AS 姓名, m.role AS 职务, m.joinDate AS 入社时间, m.status AS 状态
ORDER BY 状态, 入社时间;

// ---------- F6 活动报名与签到查询（谁报名了却没来）----------
// 预期：秋季观星夜 报名 4 人，其中王梓涵/陈嘉禾 是「报名未签到」
MATCH (a:Activity {activityId:'A01'})<-[r:SIGNED_UP]-(s:Student)
OPTIONAL MATCH (s)-[att:ATTENDED]->(a)
RETURN a.name AS 活动, s.name AS 学生, r.status AS 报名状态,
       CASE WHEN att IS NULL THEN '报名未到' ELSE '已签到' END AS 签到情况
ORDER BY 签到情况 DESC, 学生;

// ---------- F7 场地占用查询 ----------
// 预期：东区操场 3 场活动，其中 2025-10-18 有两场
MATCH (a:Activity)-[:HELD_AT]->(v:Venue {venueId:'V01'})
RETURN v.name AS 场地, a.date AS 日期, a.name AS 活动, a.status AS 状态
ORDER BY 日期;

// ---------- F8 场地冲突检测（核心「会算」）----------
// 预期：检出 1 处冲突 —— 东区操场 2025-10-18：秋季观星夜 vs 校园人像外拍
MATCH (a1:Activity)-[:HELD_AT]->(v:Venue)<-[:HELD_AT]-(a2:Activity)
WHERE a1.date = a2.date AND a1.activityId < a2.activityId
RETURN v.name AS 场地, a1.date AS 冲突日期, a1.name AS 活动一, a2.name AS 活动二,
       '同一天同一场地，需要改期' AS 建议;

// ---------- F9 招新转化查询（报名了但没正式入社）----------
// 预期：李思远、周雨桐（状态均为待审核）
MATCH (s:Student)-[ap:APPLIED_TO]->(r:Recruitment {recruitId:'R01'})-[:FOR_CLUB]->(c:Club)
WHERE NOT (s)-[:MEMBER_OF]->(c)
RETURN s.name AS 学生, s.major AS 专业, ap.status AS 申请状态, c.name AS 社团
ORDER BY 学生;

// ---------- F10 人物参与记录查询 ----------
// 预期：陈嘉禾 跨 2 个社团（星野天文社 / 拾光摄影社）、报名 1 场活动（秋季观星夜）、暂无签到记录
MATCH (s:Student {studentId:'S003'})
OPTIONAL MATCH (s)-[m:MEMBER_OF]->(c:Club)
OPTIONAL MATCH (s)-[r:SIGNED_UP]->(a:Activity)
OPTIONAL MATCH (s)-[:ATTENDED]->(a2:Activity)
OPTIONAL MATCH (s)-[:WON]->(w:Award)
RETURN s.name AS 学生, s.major AS 专业,
       collect(DISTINCT c.name)  AS 加入社团,
       collect(DISTINCT m.role)  AS 担任职务,
       collect(DISTINCT a.name)  AS 报名活动,
       collect(DISTINCT a2.name) AS 已签到活动,
       collect(DISTINCT w.name)  AS 获奖;

// ---------- F17 兴趣匹配推荐（找没入社但有兴趣的人）----------
// 预期：李思远（兴趣含天文观测，且不在天文社）
MATCH (s:Student)-[:HAS_TAG]->(g:InterestTag {tagId:'G01'})
MATCH (c:Club {clubId:'C01'})
WHERE NOT (s)-[:MEMBER_OF]->(c)
RETURN s.name AS 学生, s.major AS 专业, g.name AS 兴趣, c.name AS 推荐社团;

// ---------- F33 报名者筛选与匹配（本版新增）----------
// 思路：用「报名记录 → 招新计划 → 社团 → 社团标签 → 学生兴趣标签」这条关系链算匹配度
// 预期：李思远 命中「天文观测」匹配度 1；周雨桐 未命中（无共同标签）
MATCH (r:Recruitment {recruitId:'R01'})-[:FOR_CLUB]->(c:Club)
MATCH (s:Student)-[:APPLIED_TO]->(r)
OPTIONAL MATCH (s)-[:HAS_TAG]->(g:InterestTag)<-[:TAGGED_WITH]-(c)
RETURN s.name AS 报名学生, s.major AS 专业,
       collect(DISTINCT g.name) AS 命中标签,
       count(DISTINCT g) AS 匹配度
ORDER BY 匹配度 DESC, 报名学生;

// ---------- F32 跨社团成员重叠查询（一人多社团）----------
// 预期：陈嘉禾 同时参加 2 个社团
MATCH (s:Student)-[:MEMBER_OF]->(c:Club)
WITH s, collect(c.name) AS 社团列表, count(c) AS 社团数
WHERE 社团数 > 1
RETURN s.name AS 学生, 社团列表, 社团数, '注意活动时间冲突' AS 提示
ORDER BY 社团数 DESC;

// ---------- 通用自检（截图留档用）----------
MATCH (n) RETURN count(n) AS 实体总数;                 // 应为 34
MATCH ()-[r]->() RETURN count(r) AS 关系总数;           // 应为 73
MATCH (n) RETURN labels(n)[0] AS 类型, count(*) AS 数量 ORDER BY 数量 DESC;
