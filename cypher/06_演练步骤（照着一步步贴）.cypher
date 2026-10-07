// ============================================================
// 06 演练步骤（照着一步步贴进 Neo4j Browser）
// 用法：每次只复制「一步」的代码（▶ 标记到下一条 ▶ 之前），粘进输入框，Ctrl+Enter
// 每步下面都写了「应该看到」，对不上就往下看手册第四部分
// ============================================================

// ▶ 第 0-1 步 · 确认实体进库了（赛题：录入不少于 20 个实体）
//    应该看到：一个格子，数字必须是 35（2026-10-07 补了 C04 跑者联盟，原来是 34）
MATCH (n) RETURN count(n) AS 实体总数;

// ▶ 第 0-2 步 · 确认关系也进库了（赛题：实体之间建立关系）
//    应该看到：一个格子，数字必须是 74（原来是 73；新增 1 条 C04→G04 长跑标签）
MATCH ()-[r]->() RETURN count(r) AS 关系总数;

// ▶ 第 1 步 · 社团成员名单（F5（必须有））
//    应该看到：4 行：林一舟（社长·在册）、赵敏（观测部部长·在册）、陈嘉禾（成员·在册）、郑亦航（成员·已退出）
MATCH (s:Student)-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
RETURN s.name AS 姓名, m.role AS 职务, m.joinDate AS 入社时间, m.status AS 状态
ORDER BY 状态, 入社时间;

// ▶ 第 2 步 · 活动报名与签到（谁报名却没来）（F6（必须有））
//    应该看到：4 行：林一舟、赵敏 是「已签到」；陈嘉禾、王梓涵 是「报名未到」
MATCH (a:Activity {activityId:'A01'})<-[r:SIGNED_UP]-(s:Student)
OPTIONAL MATCH (s)-[att:ATTENDED]->(a)
RETURN a.name AS 活动, s.name AS 学生, r.status AS 报名状态,
       CASE WHEN att IS NULL THEN '报名未到' ELSE '已签到' END AS 签到情况
ORDER BY 签到情况 DESC, 学生;

// ▶ 第 3 步 · 场地占用查询（F7（必须有））
//    应该看到：3 行：东区操场被 3 场活动占用，其中 2025-10-18 有两场
MATCH (a:Activity)-[:HELD_AT]->(v:Venue {venueId:'V01'})
RETURN v.name AS 场地, a.date AS 日期, a.name AS 活动, a.status AS 状态
ORDER BY 日期;

// ▶ 第 4 步 · 场地冲突检测（F8（必须有）★最能打的一条）
//    应该看到：1 行：东区操场 · 2025-10-18 · 秋季观星夜 vs 校园人像外拍
MATCH (a1:Activity)-[:HELD_AT]->(v:Venue)<-[:HELD_AT]-(a2:Activity)
WHERE a1.date = a2.date AND a1.activityId < a2.activityId
RETURN v.name AS 场地, a1.date AS 冲突日期, a1.name AS 活动一, a2.name AS 活动二,
       '同一天同一场地，需要改期' AS 建议;

// ▶ 第 5 步 · 招新转化（报名了却没转正）（F9（必须有））
//    应该看到：2 行：李思远（哲学）、周雨桐（汉语言文学），申请状态都是「待审核」
MATCH (s:Student)-[ap:APPLIED_TO]->(r:Recruitment {recruitId:'R01'})-[:FOR_CLUB]->(c:Club)
WHERE NOT (s)-[:MEMBER_OF]->(c)
RETURN s.name AS 学生, s.major AS 专业, ap.status AS 申请状态, c.name AS 社团
ORDER BY 学生;

// ▶ 第 6 步 · 人物参与记录（一个人干了什么）（F10（必须有））
//    应该看到：1 行：陈嘉禾 · 新闻传播 · 加入社团 [星野天文社, 拾光摄影社] · 报名活动 [秋季观星夜] · 已签到 [] · 获奖 []
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

// ▶ 第 7 步 · 兴趣匹配推荐（F17（应该有））
//    应该看到：1 行：李思远 · 哲学 · 天文观测 · 星野天文社
MATCH (s:Student)-[:HAS_TAG]->(g:InterestTag {tagId:'G01'})
MATCH (c:Club {clubId:'C01'})
WHERE NOT (s)-[:MEMBER_OF]->(c)
RETURN s.name AS 学生, s.major AS 专业, g.name AS 兴趣, c.name AS 推荐社团;

// ▶ 第 8 步 · 报名者筛选与匹配（本产品新增）（F33（应该有）★最能打的一条）
//    应该看到：2 行：李思远 命中标签 [天文观测]、匹配度 1；周雨桐 命中标签 []、匹配度 0
MATCH (r:Recruitment {recruitId:'R01'})-[:FOR_CLUB]->(c:Club)
MATCH (s:Student)-[:APPLIED_TO]->(r)
OPTIONAL MATCH (s)-[:HAS_TAG]->(g:InterestTag)<-[:TAGGED_WITH]-(c)
RETURN s.name AS 报名学生, s.major AS 专业,
       collect(DISTINCT g.name) AS 命中标签,
       count(DISTINCT g) AS 匹配度
ORDER BY 匹配度 DESC, 报名学生;

// ▶ 第 9 步 · 跨社团成员（一个人参加多个社团）（F32（可以有））
//    应该看到：1 行：陈嘉禾 · [星野天文社, 拾光摄影社] · 2
MATCH (s:Student)-[:MEMBER_OF]->(c:Club)
WITH s, collect(c.name) AS 社团列表, count(c) AS 社团数
WHERE 社团数 > 1
RETURN s.name AS 学生, 社团列表, 社团数, '注意活动时间冲突' AS 提示
ORDER BY 社团数 DESC;

// ▶ 第 10 步 · 图谱总览（可视化原型）（F1（必须有））
//    应该看到：一片圆点和连线；点结果卡片上的 Graph 标签即可看到
MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 150;

// ▶ 第 11 步 · 按类型统计（都有哪些对象）（数据概览）
//    应该看到：11 行：学生 8、活动 4、兴趣标签 4、社团 4、部门 3、场地 3、老师 2、招新 2、通知 2、获奖 2、学期 1
MATCH (n) RETURN labels(n)[0] AS 类型, count(*) AS 数量 ORDER BY 数量 DESC;

// ▶ 第 12 步 · 确认「跑者联盟」挂上了（C04 补漏的验收点）
//    应该看到：4 行，其中 A04 夜跑打卡周 的主办社团是 C04 跑者联盟（不再是 C03 拾光摄影社）
MATCH (c:Club)-[:HOSTS]->(a:Activity)
RETURN c.clubId AS 社团编号, c.name AS 主办社团, a.activityId AS 活动编号, a.name AS 活动
ORDER BY 活动编号;

// ▶ 第 A1-1 步 · 动作一 · 执行前（李思远还没入社）（F11 加入社团）
//    应该看到：第一行：李思远 · 已加入社团 [] · 社团数 0；第二行：星野天文社 · 在册成员数 3
MATCH (s:Student {studentId:'S005'})
OPTIONAL MATCH (s)-[:MEMBER_OF]->(c:Club)
RETURN s.name AS 学生, collect(c.name) AS 已加入社团, count(c) AS 社团数;

MATCH (s:Student)-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
WHERE m.status = '在册'
RETURN c.name AS 社团, count(s) AS 在册成员数;

// ▶ 第 A1-2 步 · 动作一 · 执行（把他加进社团）（F11）
//    应该看到：显示 "Set 5 properties" 之类的提示，说明写入成功
MATCH (s:Student {studentId:'S005'})-[ap:APPLIED_TO]->(:Recruitment)-[:FOR_CLUB]->(c:Club {clubId:'C01'})
MERGE (s)-[m:MEMBER_OF]->(c)
SET m.role = '成员', m.joinDate = date(), m.status = '在册', ap.status = '已通过';

// ▶ 第 A1-3 步 · 动作一 · 执行后（人数 +1）（F11）
//    应该看到：第一行：李思远 · 星野天文社 · 成员 · 在册；第二行：在册成员数 4（原来是 3）
MATCH (s:Student {studentId:'S005'})-[m:MEMBER_OF]->(c:Club)
RETURN s.name AS 学生, c.name AS 社团, m.role AS 职务, m.status AS 状态;

MATCH (s:Student)-[m:MEMBER_OF]->(c:Club {clubId:'C01'})
WHERE m.status = '在册'
RETURN c.name AS 社团, count(s) AS 在册成员数;

// ▶ 第 A2-1 步 · 动作二 · 执行前（看剩余名额）（F12 报名活动）
//    应该看到：秋季观星夜 · 总名额 40 · 剩余名额 36 · 报名中
MATCH (a:Activity {activityId:'A01'})
RETURN a.name AS 活动, a.capacity AS 总名额, a.remaining AS 剩余名额, a.status AS 状态;

// ▶ 第 A2-2 步 · 动作二 · 执行（报名并扣名额）（F12）
//    应该看到：提示 Create 1 relationship / Set 3 properties
MATCH (s:Student {studentId:'S008'}), (a:Activity {activityId:'A01'})
WHERE a.remaining > 0
MERGE (s)-[r:SIGNED_UP]->(a)
ON CREATE SET r.signedAt = datetime(), r.status = '已报名', a.remaining = a.remaining - 1;

// ▶ 第 A2-3 步 · 动作二 · 执行后（名额 -1、名单 +1）（F12）
//    应该看到：剩余名额 35（原 36）；报名名单 5 人：林一舟、赵敏、陈嘉禾、王梓涵、郑亦航
MATCH (a:Activity {activityId:'A01'})<-[r:SIGNED_UP]-(s:Student)
RETURN a.name AS 活动, a.remaining AS 剩余名额, collect(s.name) AS 报名名单;

// ▶ 第 A3-1 步 · 动作三 · 执行前（王梓涵在册）（F14 成员退出）
//    应该看到：王梓涵 · 拾光摄影社 · 在册 · 2023-10-11
MATCH (s:Student {studentId:'S004'})-[m:MEMBER_OF]->(c:Club {clubId:'C03'})
RETURN s.name AS 学生, c.name AS 社团, m.status AS 状态, m.joinDate AS 入社时间;

// ▶ 第 A3-2 步 · 动作三 · 执行（改成已退出）（F14）
//    应该看到：提示 Set 2 properties
MATCH (s:Student {studentId:'S004'})-[m:MEMBER_OF]->(c:Club {clubId:'C03'})
SET m.status = '已退出', m.quitDate = date();

// ▶ 第 A3-3 步 · 动作三 · 执行后（在册 -1，关系还在）（F14）
//    应该看到：拾光摄影社 · 在册 2 · 已退出 1；星野天文社 · 在册 4 · 已退出 1
MATCH (s:Student)-[m:MEMBER_OF]->(c:Club)
RETURN c.name AS 社团,
       count(CASE WHEN m.status = '在册' THEN 1 END) AS 在册成员,
       count(CASE WHEN m.status = '已退出' THEN 1 END) AS 已退出
ORDER BY 社团;
