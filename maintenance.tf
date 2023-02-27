variable "stg-maintenance-priority" {
  default = 150 # change to 50 when maintenance mode, else 150
}
variable "maintenance_body" {
 default = <<EOF
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta name="viewport" content="width=device-width"/>
    <meta charSet="utf-8"/>
    <title>Page not found</title>
    <meta name="next-head-count" content="5"/>
    <link rel="stylesheet" href="https://s3.ap-northeast-1.amazonaws.com/static.matsuhub.link/maintenance.css" >
  </head>
  <body>
    <div class='flex justify-center mb-40'>
      <div class='text-center pt-20'>
        <h1 class='text-3xl'>ただいまメンテナンス中です</h1>
        <div class='mx-auto border-b mb-7' style='width: 75%; border-color: #0FA8A2;'></div>
        <div>ただいまメンテナンス中です</div>
        <div>
          <img src='https://s3.ap-northeast-1.amazonaws.com/static.matsuhub.link/dummy-404.png' alt='' width='300'  height='250' />
        </div>
      </div>
    </div>
  </body>
</html>
EOF
}
