require 'spec_helper'

describe FreshConnection::ConnectionManager do
  before(:each) do
    @cm = FreshConnection::ConnectionManager.new
  end

  after(:each) do
    @cm.clear_all_connections!
  end

  context "#slave_connection" do
    it "same connection in one thread" do
      c = @cm.slave_connection
      expect(c).to equal(@cm.slave_connection)
    end

    it "multi connections in several thread" do
      threads_num = 5
      threads = []
      threads_num.times do |i|
        threads << Thread.new do
          @cm.slave_connection
        end
      end
      threads.each(&:join)

      connections = @cm.instance_variable_get("@slave_connections").values
      expect(connections.size).to eq(threads_num)
      before_connection = nil
      connections.each do |c|
        expect(c).not_to equal(before_connection)
        before_connection = c
      end
    end
  end

  context "#put_aside!" do
    it "current thread connection disconnect" do
      threads_num = 5
      threads = []
      threads_num.times do |i|
        threads << Thread.new do
          @cm.slave_connection
        end
      end
      threads.each(&:join)

      current_connection = @cm.slave_connection
      @cm.put_aside!
      expect(current_connection.active?).to be_falsey

      connections = @cm.instance_variable_get("@slave_connections").values
      expect(connections.size).to eq(threads_num)
      connections.each do |c|
        expect(c.active?).to be_truthy
        expect(c).not_to equal(current_connection)
      end
    end
  end

  context "#clear_all_connections!" do
    it "all connections disconnect" do
      threads_num = 5
      threads = []
      threads_num.times do |i|
        threads << Thread.new do
          @cm.slave_connection
        end
      end
      threads.each(&:join)

      connections = @cm.instance_variable_get("@slave_connections").values

      @cm.clear_all_connections!
      expect(@cm.instance_variable_get("@slave_connections")).to be_empty
      connections.each do |c|
        expect(c.active?).to be_falsey
      end
    end
  end
end
