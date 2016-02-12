defmodule HNE.Mailer do
  @moduledoc """
  Module sets up mailing config as well as email sending functionality.
  """

  @doc """
  delivers mail.
  """
  def deliver(email) do
    Mailman.deliver(email, config)
  end

  @doc """
  smtp config for sending email
  """
  def config do
    %Mailman.Context{
    config: %Mailman.SmtpConfig{ relay: "smtp.gmail.com",                 
                                 port: 587,
                                 username: "mail@mail.com",
                                 password: "password",
                                 tls: :always },                                            
    composer: %Mailman.EexComposeConfig{}
    }
  end

  @doc """
  sets up mail for delivery including new title and link.
  """
  def sending_email(title, link) do
    %Mailman.Email
    {
      subject: "New Elixir/Erlang Article!",
      from: "marl@mail.com",
      to: [ "mail@mail.com" ],
      data: [
        name: "Mark"
        ],
      html: """
            <html>
            <body>
             <b>Hello <%= name %></b>! New article : <a href="#{link}">#{title}</a>
            </body>
            </html>
            """
    }
  end
end
