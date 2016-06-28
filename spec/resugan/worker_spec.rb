require 'spec_helper'

class TestObject
  def method1(params)
    puts params
  end

  def methodx(params)
  end
end

describe Resugan::Worker do

  it 'has a version number' do
    expect(Resugan::Worker::VERSION).not_to be nil
  end

  it 'places events in a queue instead' do
    expect_any_instance_of(TestObject).to receive(:method1)

    _listener :event1 do |params|
      TestObject.new.method1(params)
    end

    resugan {
      _fire :event1
    }

    monitor = Resugan::Worker::Monitor.new
    monitor.send(:eval_queue)
  end

  context "namespaces" do
    before :all do
      _listener :event1, namespace: 'group1' do |params|
        TestObject.new.method1(params)
      end

      _listener :event1, namespace: 'group2' do |params|
        TestObject.new.methodx(params)
      end
    end

    it "respects namespaces" do
      expect_any_instance_of(TestObject).to receive(:method1)

      resugan "group1" do
        _fire :event1
      end

      monitor = Resugan::Worker::Monitor.new "group1"
      monitor.send(:eval_queue)
    end

    it "respects namespaces" do
      expect_any_instance_of(TestObject).to receive(:methodx)

      resugan "group2" do
        _fire :event1
      end

      monitor = Resugan::Worker::Monitor.new "group2"
      monitor.send(:eval_queue)
    end
  end
end
