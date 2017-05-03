# ActionCable岛上历险记

ActionCable 通过使用 WebSocket 协议，可以实现从Server端主动向客户端推送消息。 同时也在客户端建立了通向Server端的连接，以保证消息推送的安全性和可靠性。简单来说就是能实现一个实时功能。[RailsGuides](http://guides.ruby-china.org/action_cable_overview.html)

## 理解 ActionCable

在写代码之前，我们要明白我们需要做什么工作，以及怎么做到这一步。

首先需要确认的是连接关系，有了连接基础后，再明确用户需要订阅哪些频道。通过一定条件去触发发布，发布的时候会通过频道，将信息传递给订阅了这个频道的人。

###  如何连接

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', current_user.email
    end

    protected
      def find_verified_user
        if verified_user = env['warden'].user
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

在这里，我们做了什么，首先是能传递 `current_user` ，再来就是只有登陆的用户能够进行连接。

```javascript
(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
}).call(this);
```

在这里，会创建连接用户，并将通过默认的 `/cable` 地址和服务器建立连接。

### 创建我们的频道

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak
  end
end
```

`subscribed` 和 ` unsubscribed` 是默认就生成的。`subscribed`表示的是当客户端连接上来的时候使用的方法。`unsubscribed`表示的是当客户端与服务器失去连接的时候使用的方法。

### 订阅频道

那订阅是怎样被触发的呢？

```coffeescript
#app/assets/javascripts/cable/subscriptions/chat.coffee
App.chat = App.cable.subscriptions.create "ChatChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
  disconnected: ->
    # Called when the subscription has been terminated by the server
  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
  speak: ->
    @perform 'speak'

```

上述代码创建了订阅。connected 与 subscribed 的区别也只是一个前端一个后端。

但相比 ChatChannel 我们可以明显的看见多了一个 received。只有 received 接受服务器传来的发布的信息数据。我们在这里编写，订阅后会接受数据后实现怎样的操作。

在订阅的基础上，我们通过流(stream)来将发布的内容发送给订阅者。

```ruby
# app/channels/chat_channel.rb
...
stream_from "chat_#{params[:room]}"
...
```

有了和模型关联的流，就可以从模型和频道生成所需的广播。

### 怎样发布

从被触发发布的后来将一将这个流程。触发的情况有两种。

触发在后端：

通过

```ruby
ActionCable.server.broadcast("chat_speak", data)
```

找到指定的频道，以及给这个频道传递JSON类型的数据。

找到订阅了这个频道的用户，执行在 chat.coffee 文件 rejected 里的代码。

触发在前端：

通过

```coffeescript
speak: ->
  @perform 'speak'
```

调用

```ruby
# app/channels/chat_channel.rb
...
  def speak
  end
...
```

在 def speak 中写明需要进行的操作。



### ActiveJob

我们利用 activejob 在 ActionCable 以外的地方轻松触发 ActionCable 的发布。

在

```ruby
#app/jobs/message_broadcast_job.rb
class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast 'room_channel', message: render_message(message)
  end

  private
    def render_message(message)
      ApplicationController.renderer.render(partial: 'messages/message', locals: { message: message })
    end
end
```

后，我们就可以在

```ruby
#app/models/message.rb
class Message < ApplicationRecord
  after_create_commit { MessageBroadcastJob.perform_later self }
end
```

中，触发发布了。



## 在Production中实现

修改默认 ActionCable Url

```ruby
#config/environments/production.rb
config.action_cable.url = 'ws://yuna.com/cable' # ws:// is non-secure, wss:// is secure
config.action_cable.allowed_request_origins = [ 'http://yuna.com' ]
```

因为有使用到 redis，所以我们需要注意与 redis 的连接

```yaml
#config/cable.yml
development:
  adapter: async

test:
  adapter: async

production:
  adapter: redis
  url: redis://localhost:6379/1
```

如果没有 redis，下载它，并注意 **/etc/redis/redis.conf** 里面的设置是不是 127.0.0.1:6379

```
apt-get install redis-server
service redis-server start
```

添加 ActiionCable 在 metatag 里

```ruby
#app/views/layouts/application.html.erb
<%= action_cable_meta_tag %>
```

接下来是Nginx的设置

```
upstream yuna {
 server unix:/home/yuna/tmp/yuna.sock;
}
server {
 listen 10.10.10.10:80;
 server_name yuna.com;

 access_log /home/yuna/log/access.log;
 error_log /home/yuna/log/error.log;
 root /home/yuna/public;

 location / {
   try_files /maint.html $uri @ruby;
 }

 location @ruby {
   proxy_pass http://yuna;
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   proxy_set_header Host $http_host;
   proxy_redirect off;
 }

 location /cable {
   proxy_pass http://yuna;
   proxy_http_version 1.1;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "upgrade";
 }
}
```

我们还要注意 puma

```
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count
bind "unix:/home/yuna/tmp/yuna.sock"
environment ENV.fetch("RAILS_ENV") { "production" }
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
daemonize true
pidfile '/home/yuna/tmp/pids/puma.pid'
```

接下来就可以启动你的 App了。

```
cd /home/yuna
puma -C config/puma.rb -e production
```

参考:

[RAILS 5 + PUMA + NGINX + ACTIONCABLE](http://spannersoftware.com/rails-5-puma-nginx-actioncable/)

[websocket 序列文章目录](https://www.rails365.net/articles/websocket-xu-lie-wen-zhang-mu-lu)

[rails5之ActionCable](http://www.jianshu.com/p/2bc9533b9bfb)

[聊一聊ActionCable背后的技术](http://www.jianshu.com/p/f08393da80b5)

[Create a Chat App with Rails 5, ActionCable, and Devise](https://www.sitepoint.com/create-a-chat-app-with-rails-5-actioncable-and-devise/)

[Action Cable 概览](http://guides.ruby-china.org/action_cable_overview.html)
