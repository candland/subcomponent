require_relative "lib/subcomponent/version"

Gem::Specification.new do |spec|
  spec.name = "subcomponent"
  spec.version = Subcomponent::VERSION
  spec.authors = ["candland"]
  spec.email = ["candland@gmail.com"]
  spec.homepage = "https://candland.net/subcomponent"
  spec.summary = "Very simple view based components"
  spec.description = "Very simple view based components."
  spec.license = "MIT"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/candland/subcomponent"
  spec.metadata["changelog_uri"] = "https://github.com/candland/subcomponent/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0"
end
