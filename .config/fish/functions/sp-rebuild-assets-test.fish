# Defined in /tmp/fish.EaOT9h/sp-rebuild-assets-test.fish @ line 1
function sp-rebuild-assets-test
    bundle exec bin/rails assets:clobber assets:precompile && RAILS_ENV=test bin/webpack && yarn webpack:build:manage --targets test
end
