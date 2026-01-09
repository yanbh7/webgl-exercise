# ---------- 第一阶段：构建 ----------
FROM node:22-alpine AS builder

WORKDIR /app

# 先复制依赖文件（利用缓存）
COPY package*.json ./
RUN npm install

# 再复制源代码
COPY . .

# 构建
RUN npm run build


# ---------- 第二阶段：运行 ----------
FROM nginx:alpine

# 删除默认配置
RUN rm /etc/nginx/conf.d/default.conf

# 复制自定义 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 把构建好的 dist 拷贝到 nginx 目录
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
