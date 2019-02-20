FROM node:11.9.0-alpine

WORKDIR /home/node/front-end

# Install deps
COPY ./package* ./
RUN npm install && \
    npm cache clean --force

# Expose ports (for orchestrators and dynamic reverse proxies)
EXPOSE 3000

# Start development
CMD npm start

# ###############################################################################
# # Step 1 : Builder image
# #
# FROM node:9-alpine AS builder

# # Define working directory and copy source
# WORKDIR /home/node/front-end
# COPY . .
# # Install dependencies and build whatever you have to build 
# # (babel, grunt, webpack, etc.)
# RUN npm install && npm run build

# ###############################################################################
# # Step 2 : Run image
# #
# FROM node:9-alpine
# ENV NODE_ENV=production
# WORKDIR /home/node/front-end

# # Install deps for production only
# COPY ./package* ./
# RUN npm install && \
#     npm cache clean --force
# # Copy builded source from the upper builder stage
# COPY --from=builder /home/node/front-end/build ./build

# # Expose ports (for orchestrators and dynamic reverse proxies)
# EXPOSE 3001

# # Start the app
# CMD npm start
