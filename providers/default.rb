# encoding: UTF-8

def interpolation
  new_resource.interpolation(
    if new_resource.interpolation.nil?
      node['mysql_tuning']['interpolation']
    else
      new_resource.interpolation
    end
  )
end

def configuration_samples
  new_resource.configuration_samples(
    if new_resource.configuration_samples.nil?
      node['mysql_tuning']['configuration_samples']
    else
      new_resource.configuration_samples
    end
  )
end

def configs
  node['mysql_tuning'].keys.select { |i| i[/\.cnf$/] }
end

action :create do
  self.class.send(:include, ::MysqlTuning::CookbookHelpers)

  # Avoid interpolating already defined configuration values
  non_interpolated_keys =
    node['mysql_tuning']['tuning.cnf'].reduce({}) do |r, (ns, cnf)|
      r[ns] = cnf.keys
    end

  # Interpolate configuration values
  tuning_cnf = cnf_from_samples(
    configuration_samples,
    interpolation,
    non_interpolated_keys
  )
  node.default['mysql_tuning']['tuning.cnf'] =
    Chef::Mixin::DeepMerge.hash_only_merge(
      tuning_cnf,
      node['mysql_tuning']['tuning.cnf']
    )

  new_resource.updated_by_last_action(false)
  configs.each do |config|
    r = mysql_tuning_cnf config do
      service_name new_resource.service_name
      directory new_resource.directory
      mysql_port new_resource.mysql_port
      action :create
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

end

action :delete do

  new_resource.updated_by_last_action(false)
  configs.each do |config|
    r = mysql_tuning_cnf config do
      service_name new_resource.service_name
      directory new_resource.directory
      mysql_user new_resource.mysql_user # not used on delete
      mysql_password new_resource.mysql_password
      mysql_port new_resource.mysql_port
      action :delete
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

end
