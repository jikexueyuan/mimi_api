秘密服务器端代码
================

Ruby写的秘密服务器端代码

环境：
Ruby + MongoDB + Grape


# MiMi_Api的配置部署


## 首先安装Ruby环境

首先更新你的服务器，我一般用的是Debian，国际惯例

 `sudo apt-get update && sudo apt-get upgrade`

然后用普通用户安装RVM，RVM是一个管理Ruby版本的软件，当然你也可以选择Rbenv，紧紧是个人喜好以及熟悉问题：

`\curl -sSL https://get.rvm.io | bash -s stable`

执行过后，需要再执行这个确保本机配置正确：

`source ~/.rvm/scripts/rvm`

此刻，如果你打出`rvm -v`，终端出现如下字样，那么恭喜你，rvm安装成功

`rvm 1.25.29 (stable) by Wayne E. Seguin <wayneeseguin@gmail.com>, Michal Papis <mpapis@gmail.com> [https://rvm.io/]`

然后再用RVM安装Ruby，可以用`rvm list known`来列出RVM支持的Ruby版本，这里我们选择2.1.2版本，执行`rvm install 2.1.2`就可以安装Ruby了，在这当中你可能需要输入密码来安装依赖。

安装好之后，还需要用`rvm use 2.1.2`来确保系统使用的Ruby版本。

##  安装

把仓库clone到本地

    git clone https://github.com/jikexueyuan/mimi_api.git
    
然后执行 `bundle`

    cd mimi_api && bundle
    
## MongoDB 配置


先略过 (｡-_-｡)

    
##  unicorn 配置

在上面的bundle中已经安装了unicorn，这里我们选择nginx来配合。
  
    sudo apt-get install nginx
    
然后需要在`mimi_api/config`下建立`unicorn.rb` 文件，并写入如下内容

    # Set the working application directory
    # working_directory "/path/to/your/app"
    working_directory "/www/mimi"

	# Unicorn PID file location
	# pid "/path/to/pids/unicorn.pid"
	pid "/www/mimi/unicorn.pid"
	
	# Path to logs
	# stderr_path "/path/to/log/unicorn.log"
	# stdout_path "/path/to/log/unicorn.log"
	stderr_path "/www/mimi/log/unicorn.log"
	stdout_path "/www/mimi/log/unicorn.log"
	
	# Unicorn socket
	# listen "/tmp/unicorn.[app name].sock"
	listen "/tmp/unicorn.mimi.sock"
	
	# Number of processes
	# worker_processes 4
	worker_processes 2
	
	# Time-out
	timeout 30

注意的是，`/www/mimi`是我的本地目录，需要你改成你clone到服务器上的目录。

然后配置nginx，新建或者修改如下文件`/etc/nginx/conf.d/default.conf`，写入如下内容

    upstream app {
		    # Path to Unicorn SOCK file, as defined previously
		    server unix:/tmp/unicorn.mimi.sock fail_timeout=0;
		}
	
	server {
	
	
	    listen 80;
	    server_name localhost;
	
	    # Application root, as defined previously
	    root /home/ishell/www/mimi/public;
	
	    try_files $uri/index.html $uri @app;
	
	    location @app {
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	        proxy_set_header Host $http_host;
	        proxy_redirect off;
	        proxy_pass http://app;
	        }
	
	        error_page 500 502 503 504 /500.html;
		    client_max_body_size 4G;
		    keepalive_timeout 10;
    }

    
然后在`mimi_api`目录执行 

    unicorn_rails -c config/unicorn.rb -D
    
接着执行

    sudo service nginx restart
    
这时打开`http://你的ip/api/v1/nimings/hey` 就可以看到 `"say hey from NiMing "`