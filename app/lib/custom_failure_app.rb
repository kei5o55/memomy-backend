# app/lib/custom_failure_app.rb
class CustomFailureApp < Devise::FailureApp
  def respond
    if request.format == :json || request.headers["Accept"] =~ /json/
      json_error_response
    else
      super
    end
  end

  private

  def json_error_response
    self.status = :unauthorized
    self.content_type = "application/json"
    self.response_body = {
      error: "メールアドレスまたはパスワードが正しくありません"
    }.to_json
  end
end
