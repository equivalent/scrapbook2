# published at https://gist.github.com/equivalent/9a97dff5a8a24bf84868d913a512add7
#
require 'rspec'

class Membership
  attr_accessor :type, :owner

  def free?
    type == 'free'
  end

  def paid?
    type == 'paid'
  end

  def unassigned?
    owner.nil?
  end

  # purely for debugging purpose
  def to_s
    "I'm a Membership type=#{type} and I'm #{unassigned? ? 'unassigned' : 'assigned'}"
  end
  alias inspect to_s
end

class MembershipCollection
  include Enumerable

  delegate :empty?, to: :@members

  def initialize(*members)
    @members = members.flatten
  end

  def each(*args, &block)
    @members.each(*args, &block)
  end

  def free
    select { |m| m.free? }
  end

  def paid
    select { |m| m.paid? }
  end

  def unassigned
    select { |m| m.unassigned? }
  end
end

RSpec.describe MembershipCollection do
  subject { described_class.new(memberships) }
  let(:free_membership) { Membership.new.tap { |m| m.type = 'free'} }
  let(:paid_membership) { Membership.new.tap { |m| m.type = 'paid'} }

  context 'when no memberships' do
    let(:memberships) { [] }

    it { expect(subject).to be_blank }
    it { expect(subject).to be_empty }
    it { expect(subject.free).to be_empty }
    it { expect(subject.paid).to be_empty }
  end

  context 'when free memberships' do
    let(:memberships) { [free_membership] }

    it { expect(subject).not_to be_blank }
    it { expect(subject).not_to be_empty }
    it { expect(subject.free).to eq([free_membership]) }
    it { expect(subject.paid).to be_empty }
  end

  context 'when paid memberships' do
    let(:memberships) { [paid_membership] }

    it { expect(subject).not_to be_blank }
    it { expect(subject).not_to be_empty }
    it { expect(subject.free).to be_empty }
    it { expect(subject.paid).to eq([paid_membership]) }
  end
end
