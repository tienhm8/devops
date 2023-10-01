## Description

Dự án devops phục vụ cho việc dựng docker

## Serivces
Các service support 
- Nginx
- PHP(Hiện tại php8.1-fpm, có thể thay đổi version PHP và phiên bản xdebug tương ứng)
- Mariadb
- Postgresql
- Phpmyadmin
- Mongo
- Redis-cache
- SMTP
- Rabbitmq
- Supervisor
- Xdebug
- Opcache

## Sử dụng

### Bước 1: Clone repo đặt tên là src cùng cấp folder docker

### Bước 2: Copy .env.example -> .env

### Bước 3: Tùy chỉnh port trong .env

### Bước 4: Thay đổi giá trị server_name trong docker/nginx/conf.d/app.conf
Nhớ: Thêm vhost trong /etc/hosts

### Bước 5: Thay đổi giá trị SERVER_NAME bằng giá trị ở bước 4 trong .env
Mục đích: Để chạy được command line bằng docker

### Bước 6: Khởi chạy container
```
docker compose up -d 
```
Phiên bản docker compose thấp hơn thì chạy:

```
docker-compose up -d 
```

### Bước 7: Cài đặt vendor, phân quyềnDocker
```
docker compose exec app composer install
docker compose exec app chmod 777 -R storage
docker compose exec app php artisan key:generate
```

### Sử dụng Xdebug
B1: Cấu hình CLI Interpreter
- Ấn số 2 để thêm
![xdebug-step1.png](docker%2Ftutorial%2Fxdebug-step1.png)
- Ấn + (số 1) chọn số 2 -> Chọn From Docker, Vargant, VM, WSL, Remote...
![xdebug-step2.png](docker%2Ftutorial%2Fxdebug-step2.png)
- Chọn Docker và đúng Image (image app)
![x-debug-step3.png](docker%2Ftutorial%2Fx-debug-step3.png)
- Đảm bảo sau khi ấn OK => Xdebug hiển thị lên như ảnh

B2: Mapping path code vật lý và path docker:

Vào PHPStorm -> Settings -> Tab Server -> Ấn + để thêm thông tin sau
Host ở vị trí số 1 chính là SERVER_NAME được setting trong .env

Ấn biểu tượng cái bút để set path
![xdebug-step4.png](docker%2Ftutorial%2Fxdebug-step4.png)

Nhớ setting path cho artisan để có thể chạy được command line
![xdebug-step5.png](docker%2Ftutorial%2Fxdebug-step5.png)