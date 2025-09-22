# パスワードハッシュを自動生成するため has_secure_password を前提にしている
User.find_or_create_by!(email_address: "test@example.com") do |user|
  user.password = "123456"
end
