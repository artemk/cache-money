Gem::Specification.new do |s|
  s.name     = "ngmoco-cache-money"
  s.version  = "0.2.12"
  s.date     = "2010-04-23"
  s.summary  = "Write-through and Read-through Cacheing for ActiveRecord"
  s.email    = "teamplatform@ngmoco.com"
  s.homepage = "http://github.com/ngmoco/cache-money"
  s.description = "Cache utilities."
  s.has_rdoc = false
  s.authors  = ["Nick Kallen","Ashley Martens"]
  s.files    = [
    "README",
    "TODO",
    "UNSUPPORTED_FEATURES",
    "lib/cash/accessor.rb",
    "lib/cash/buffered.rb",
    "lib/cash/config.rb",
    "lib/cash/finders.rb",
    "lib/cash/index.rb",
    "lib/cash/local.rb",
    "lib/cash/lock.rb",
    "lib/cash/fake.rb",
    "lib/cash/query/abstract.rb",
    "lib/cash/query/calculation.rb",
    "lib/cash/query/primary_key.rb",
    "lib/cash/query/select.rb",
    "lib/cash/request.rb",
    "lib/cash/transactional.rb",
    "lib/cash/util/array.rb",
    "lib/cash/util/marshal.rb",
    "lib/cash/write_through.rb",
    "lib/cache_money.rb",
    "lib/memcached_wrapper.rb",
    "rails/init.rb",
    "init.rb"
  ]
  s.test_files = [
    "config/environment.rb",
    "config/memcached.yml",
    "db/schema.rb",
    "spec/cash/accessor_spec.rb",
    "spec/cash/active_record_spec.rb",
    "spec/cash/calculations_spec.rb",
    "spec/cash/finders_spec.rb",
    "spec/cash/lock_spec.rb",
    "spec/cash/order_spec.rb",
    "spec/cash/transactional_spec.rb",
    "spec/cash/window_spec.rb",
    "spec/cash/write_through_spec.rb",
    "spec/cash/marshal_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.add_dependency("active_record", [">= 2.2.0"])
  s.add_dependency("active_support", [">= 2.2.0"])
  # s.add_dependency("memcache-client", [">= 1.7.4 "])
  # s.add_dependency("memcached", [">= 0.13"])
end
