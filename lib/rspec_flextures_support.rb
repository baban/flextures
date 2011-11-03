# encoding: utf-8

# Rspecの内部でflextures関数を使える様にする
module RSpec::Core::Hooks
  def flextures *args
    Flextures::Loader::flextures *args
  end
end

