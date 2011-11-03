# encoding: utf-8

module Flextures
  LOAD_DIR = Config.fixture_load_directory
  DUMP_DIR = Config.fixture_dump_directory
  # �������
  module ARGS
    # �����o���E�ǂݍ��� ���ׂ��t�@�C���ƃI�v�V��������������
    def self.parse option={}
      table_names = ""
      table_names = ENV["TABLE"].split(",") if ENV["TABLE"]
      table_names = ENV["T"].split(",") if ENV["T"]
      table_names = ENV["MODEL"].constantize.table_name.split(",") if ENV["MODEL"]
      table_names = ENV["M"].constantize.table_name.split(",") if ENV["M"]
      table_names = ActiveRecord::Base.connection.tables if ""==table_names
      table_names = table_names.map{ |name| { table: name } }
      table_names = table_names.map{ |option| option.merge dir: ENV["DIR"] } if ENV["DIR"]
      table_names.first[:file]= ENV["FILE"] if ENV["FILE"] # �t�@�C�����͍ŏ��̂��̂����w��ł��Ȃ�
      table_names.first[:file]= ENV["F"] if ENV["F"]
      # read mode ����csv��yaml���݂��Ȃ��t�@�C���͕Ԃ��Ȃ�
      table_names.select! &exist if option[:mode] && option[:mode].to_sym == :read 
      table_names
    end

    # ���݂��Ă���t�@�C���ōi�荞�ށ@    
    def self.exist
      return->(name){ File.exists?("#{LOAD_DIR}#{name}.csv") or File.exists?("#{LOAD_DIR}#{name}.yml") }
    end
  end
  
  # �e�[�u�����f���̍쐬
  def self.create_model table_name
    klass = Class.new ActiveRecord::Base
    klass.table_name=table_name
    klass
  end
  
  module Dumper
    PARENT = Flextures

    # �K�؂Ȍ^�ɕϊ�
    def self.trans v
      case v
        when true;  1
        when false; 0
        else; v
      end
    end

    # csv �� fixtures �� dump 
    def self.csv format
      table_name = format[:table]
      file_name = format[:file] || table_name
      dir_name = format[:dir] || DUMP_DIR
      outfile = "#{dir_name}#{file_name}.csv"
      klass = PARENT.create_model(table_name)
      attributes = klass.columns.map { |colum| colum.name }

      CSV.open(outfile,'w') do |csv|
        csv<< attributes
        klass.all.each do |row|
          csv<< attributes.map { |column| trans(row.send(column))}
        end
      end
    end

    # yaml �� fixtures �� dump 
    def self.yml format
      table_name = format[:table]
      file_name = format[:file] || table_name
      dir_name = format[:dir] || DUMP_DIR
      outfile = "#{dir_name}#{file_name}.yml"
      klass = PARENT::create_model(table_name)
      attributes = klass.columns.map { |colum| colum.name }

      File.open(outfile,"w") do |f|
        klass.all.each_with_index do |row,idx| 
          f<< "#{table_name}_#{idx}:\n" +
            attributes.map { |column|
              v = trans row.send(column)
              "  #{column}: #{v}\n"
            }.join
        end
      end
    end
  end

  module Loader 
    PARENT = Flextures

    # �^�ɉ����ď����default�l��ݒ肷��
    COMPLETER = {
      binary:->{ 0 },
      boolean:->{ false },
      date:->{ DateTime.now },
      datetime:->{ DateTime.now },
      decimal:->{ 0 },
      float:->{ 0.0 },
      integer:->{ 0 },
      string:->{ "" },
      text:->{ "" },
      time:->{ DateTime.now },
      timestamp:->{ DateTime.now },
    }
    # �^�̕ϊ����s��
    TRANSLATER = {
      binary:->(d){ d.to_i },
      boolean:->(d){ (0==d || ""==d || !d) ? false : true },
      date:->(d){ Date.parse(d.to_s) },
      datetime:->(d){ DateTime.parse(d.to_s) },
      decimal:->(d){ d.to_i },
      float:->(d){ d.to_f },
      integer:->(d){ d.to_i },
      string:->(d){ d.to_s },
      text:->(d){ d.to_s },
      time:->(d){ DateTime.parse(d.to_s) },
      timestamp:->(d){ DateTime.parse(d.to_s) },
    }

    # csv �D��ő��݂��Ă��� fixtures �����[�h
    def self.load format
      file_name = format[:file] || format[:table]
      dir_name = format[:dir] || LOAD_DIR
      method = nil
      method = :csv if File.exist? "#{dir_name}#{file_name}.csv"
      method = :yml if File.exist? "#{dir_name}#{file_name}.yml"
      self::send(method, format) if method
    end

    # fixtures���܂Ƃ߂ă��[�h�A��Ƀe�X�gtest/unit, rspec �Ŏg�p����    
    def self.flextures *fixtures
       # :all�ł��ׂĂ�fixture�𔽉f
      fixtures = ActiveRecord::Base.connection.tables if fixtures.size== 1 and :all == fixtures.first
      
      fixtures_hash = fixtures.pop if fixtures.last and fixtures.last.is_a? Hash # �n�b�V�����o��
      fixtures.each{ |table_name| Flextures::Loader::load table: table_name }
      fixtures_hash.each{ |k,v| Flextures::Loader::load table: k, file: v } if fixtures_hash
      fixtures
    end

    # CSV�̃f�[�^�����[�h����
    def self.csv format
      table_name = format[:table].to_s
      file_name = format[:file] || table_name
      dir_name = format[:dir] || LOAD_DIR
      inpfile = "#{dir_name}#{file_name}.csv"

      klass = PARENT::create_model table_name
      attributes = klass.columns.map &:name
      filter = create_filter klass.columns, Factory[table_name]
      #filter2 = create_filter2 klass.columns, Factory[table_name]
      klass.delete_all
      CSV.open( inpfile ) do |csv|
        keys = csv.shift # key�̐ݒ�
        warning "CSV", attributes, keys
        csv.each do |values|
          klass.create filter.call values.extend(Extensions::Array).to_hash(keys)
        end
      end
    end

    # YAML�`���Ńf�[�^�����[�h����
    def self.yml format
      table_name = format[:table].to_s
      file_name = format[:file] || table_name
      dir_name = format[:dir] || LOAD_DIR
      inpfile = "#{dir_name}#{file_name}.yml"

      klass = PARENT::create_model table_name
      attributes = klass.columns.map &:name
      filter = create_filter klass.columns, Factory[table_name]
      klass.delete_all
      YAML.load(File.open(inpfile)).each do |k,h|
        warning "YAML", attributes, h.keys
        klass.create filter.call h
      end
    end
    
    # �������J���������m���ă��b�Z�[�W���o���Ă���
    def self.warning format, attributes, keys
      (attributes-keys).each { |name| print "Warning: #{format} colum is missing! [#{name}]\n" }
      (keys-attributes).each { |name| print "Warning: #{format} colum is left over! [#{name}]\n" }
    end

    # �t�B�N�X�`��������o�����l���A���H���ė~�����f�[�^�ɂ���t�B���^���쐬���ĕԂ�
    def self.create_filter columns, factory=nil
      # �e�[�u������J�����������o��
      column_hash = {}
      columns.each { |col| column_hash[col.name] = col }
      # �����⊮���K�v�Ȃ͂��̃J����
      lack_columns = columns.select { |c| !c.null and !c.default }.map &:name
      # �n�b�V�����󂯎���āA�K�v�Ȓl�ɉ��H���Ă���n�b�V���ŕԂ�
      ->(h){
        h.select! { |k,v| column_hash[k] } # �e�[�u���ɑ��݂��Ȃ��L�[����`����Ă���Ƃ��͍폜
        # �l��nil�łȂ��Ȃ�^��DB�œK�؂Ȃ��̂ɕύX
        h.each{ |k,v| nil==v || h[k] = TRANSLATER[column_hash[k].type].call(v) }
        # FactoryFilter�𓮍삳����
        st = OpenStruct.new(h)
        factory.call(st) if factory
        h = st.to_hash
        # �l��nil�̗�Ƀf�t�H���g�l����
        lack_columns.each { |k| nil==h[k] && h[k] = COMPLETER[column_hash[k].type].call }
        h
      }
    end

  end
end

