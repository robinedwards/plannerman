require 'test/unit'
require 'plan/validate'

class TC_PlanValidate < Test::Unit::TestCase

  def test_validation
    plan = Plan::Validate.new({
      :tolerance      => 0.01,
      :domain_file    => 'test/fixtures/validate/domain.pddl',
      :problem_file   => 'test/fixtures/validate/pfile01.pddl',
      :solution_file  => 'test/fixtures/validate/pfile1.soln',
    });

    plan.validate
    assert_equal(8, plan.first_quality)
    assert_equal(8, plan.second_quality)
  end

end
