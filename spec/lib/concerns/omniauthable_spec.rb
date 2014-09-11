RSpec.describe SuperbAuth::Concerns::Omniauthable do
  before do
    # Reinitialize dummy class with the only dependency on this concern
    Object.send(:remove_const, :OmniauthableClass) if Object.constants.include?(:OmniauthableClass)
    class OmniauthableClass < ActiveRecord::Base
      self.table_name = 'users'
      cattr_accessor :omniauth_providers
      self.omniauth_providers = [:facebook]
      include SuperbAuth::Concerns::Omniauthable
    end
  end

  describe '.oauth_attr' do
    it 'adds attributes to @oauth_attributes variable' do
      expect { OmniauthableClass.oauth_attr(:name) }.to change { OmniauthableClass.instance_variable_get(:@oauth_attributes) }.from({}).to({name: {}})
      expect { OmniauthableClass.oauth_attr(:sex, assign_to: :gender) }.to change { OmniauthableClass.instance_variable_get(:@oauth_attributes) }.to({name: {}, sex: { assign_to: :gender }})
    end

    it 'raises error when :if option is not a Proc' do
      expect { OmniauthableClass.oauth_attr(:name, if: :always) }.to raise_error
    end

    it 'raises error when :if option is not a Proc' do
      expect { OmniauthableClass.oauth_attr(:name, if: -> (x, y) { x + y }) }.to raise_error
    end

    it 'does not raise any error for valid :if option' do
      expect { OmniauthableClass.oauth_attr(:name, if: -> (user) { true }) }.not_to raise_error
    end
  end

  describe '#get_user_info_from_identity' do
    before do
      class OmniauthableClass < ActiveRecord::Base
        attr_accessor :email, :username, :age
        oauth_attr :email
        oauth_attr :name, assign_to: :username
        oauth_attr :age, if: -> (user) { user.age.to_i <= 0 }
      end
    end

    let(:user) { OmniauthableClass.new }
    let(:identity) { OpenStruct.new(email: 'email@example.com', name: 'Tester', age: 20) }

    context 'atrtibutes are not set' do
      it 'assigns attributes' do
        user.get_user_info_from_identity(identity)
        expect(user.email).to eq(identity.email)
        expect(user.username).to eq(identity.name)
        expect(user.age).to eq(identity.age)
      end

      it 'returns list of assigned attributes' do
        expect(user.get_user_info_from_identity(identity)).to eq([:email, :name, :age])
      end
    end

    context 'attributes were already assigned' do
      before { user.email = 'test@example.com' }
      before { user.username = 'Name' }
      before { user.age = 30 }

      it 'does not change those attributes' do
        expect { user.get_user_info_from_identity(identity) }.not_to change { user.email }
        expect { user.get_user_info_from_identity(identity) }.not_to change { user.username }
        expect { user.get_user_info_from_identity(identity) }.not_to change { user.age }
      end

      it 'returns empty array' do
        expect(user.get_user_info_from_identity(identity)).to eq([])
      end
    end
  end
end
