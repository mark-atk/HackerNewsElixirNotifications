# Hacker News Elixir Notifications

HNEN is my first attempt at an Elixir project. The apps purpose is to scan the top 150 Hacker News stories via their Firebase API and then email any news stories with either Elixir or Erlang in the title.

Currently the mailer only works with a gmail account.

##Config
Make sure to update your gmail settings in the mailer.ex config, and set your settings in gmail to allow "less secure" applications
to connect to it.

I created a separate gmail for this.


