# encoding: utf-8

# Rspec��������flextures�ؿ���Ȥ����ͤˤ���
module RSpec::Core::Hooks
  def flextures *args
    Flextures::Loader::flextures *args
  end
end

