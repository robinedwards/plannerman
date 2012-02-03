class AddDomainRequirements < ActiveRecord::Migration
  def up
    create_table :requirements do |t|
      t.string :name
    end
    create_table :domain_requirements do |t|
      t.references :domains
      t.references :requirements
    end

    add_index :requirements, :name, :unique => true

    Requirements.create(:name => 'typing')
    Requirements.create(:name => 'adl')
    Requirements.create(:name => 'preferences')
    Requirements.create(:name => 'timed-initial-literals')
    Requirements.create(:name => 'durative-actions')
    Requirements.create(:name => 'fluents')
    Requirements.create(:name => 'strips')
    Requirements.create(:name => 'derived-predicates')
    Requirements.create(:name => 'equality')
    Requirements.create(:name => 'constraints')
    Requirements.create(:name => 'conditional-effects')
    Requirements.create(:name => 'negative-preconditions')
    Requirements.create(:name => 'action-costs')
    Requirements.create(:name => 'existential-preconditions')
    Requirements.create(:name => 'universal-preconditions')
    Requirements.create(:name => 'duration-inequalities')
    Requirements.create(:name => 'numeric-fluents')

  end

  def down
    drop_table :domain_requirements
    drop_table :requirements
  end
end
