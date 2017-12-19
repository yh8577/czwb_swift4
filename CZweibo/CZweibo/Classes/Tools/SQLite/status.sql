-- 创建微博数据表 --

CREATE TABLE IF NOT EXISTS "T_status" (
"statusid" INTEGER NOT NULL,
"userid" INTEGER NOT NULL,
"status" TEXT,
"createtime" TEXT DEFAULT (datetime('now', 'localtime')),
PRIMARY KEY("statusid","userid")
);
