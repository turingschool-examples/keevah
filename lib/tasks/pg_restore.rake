require "pry"

namespace :db do
  desc "Reload the development DB from a pre-seeded db dump"
  task :pg_restore => [:environment, :drop, :create] do
    `rm /tmp/scale_up.sql`
    dump_url = "https://www.dropbox.com/s/73t5u75jlw181aa/scale_up_keevah_db_dump.sql?dl=1"
    puts "** Downloading Scale Up SQL Dump **"
    `curl -L #{dump_url} > /tmp/scale_up.sql`
    puts "** Loading Scale Up SQL Dump **"
    `psql the_pivot_development < /tmp/scale_up.sql`
    puts "** Complete! Loaded Records **"
    puts "** Users: #{User.count} **"
    puts "** Loan Requests: #{LoanRequest.count} **"
    puts "** Categories: #{Category.count} **"
    puts "** Orders: #{Order.count} **"
  end
end
