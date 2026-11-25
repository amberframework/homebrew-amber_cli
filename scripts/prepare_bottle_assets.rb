# Prepares the bottles `brew bottle --json` wrote for upload to the tap's releases,
# one release per formula. Each bottle must match the sha256 its JSON records; a
# mismatch stops the publish. Writes, inside <bottles-dir>:
#   <formula>/upload/<filename>   each bottle under the name Homebrew downloads it by
#   <formula>/release_tag.txt     <formula>-<pkg version>
#   <formula>/release_notes.md    one row per bottle with its sha256
#   list_of_formulae.txt          the formulae that have bottles, one per line
#   commit_message.txt            the release tags and bottle tags, for the commit
# usage: ruby scripts/prepare_bottle_assets.rb <bottles-dir>
require "digest"
require "fileutils"
require "json"

bottles_dir = ARGV.fetch(0)

list_of_json_paths = Dir.glob(File.join(bottles_dir, "*.bottle.json")).sort
abort "no *.bottle.json in #{bottles_dir}" if list_of_json_paths.empty?

# formula name => { "versions" => [...], "rows" => [[tag, filename, sha256, bytes], ...] }
bottles_by_formula = Hash.new { |hash, name| hash[name] = { "versions" => [], "rows" => [] } }
list_of_json_paths.each do |json_path|
  JSON.parse(File.read(json_path)).each_value do |entry|
    formula_name = entry.fetch("formula").fetch("name")
    formula_bottles = bottles_by_formula[formula_name]
    formula_bottles["versions"] << entry.fetch("formula").fetch("pkg_version")
    upload_dir = File.join(bottles_dir, formula_name, "upload")
    FileUtils.mkdir_p(upload_dir)
    entry.fetch("bottle").fetch("tags").each do |tag, bottle|
      local_path = File.join(bottles_dir, bottle.fetch("local_filename"))
      actual_sha256 = Digest::SHA256.file(local_path).hexdigest
      unless actual_sha256 == bottle.fetch("sha256")
        abort "#{bottle["local_filename"]}: sha256 #{actual_sha256} is not the recorded #{bottle["sha256"]}"
      end
      FileUtils.cp(local_path, File.join(upload_dir, bottle.fetch("filename")))
      formula_bottles["rows"] << [tag, bottle.fetch("filename"), actual_sha256, File.size(local_path)]
    end
  end
end

list_of_commit_lines = []
bottles_by_formula.keys.sort.each do |formula_name|
  formula_bottles = bottles_by_formula[formula_name]
  list_of_versions = formula_bottles["versions"].uniq
  abort "#{formula_name} bottles disagree on the version: #{list_of_versions.join(", ")}" unless list_of_versions.size == 1
  version = list_of_versions.first
  release_tag = "#{formula_name}-#{version}"
  formula_dir = File.join(bottles_dir, formula_name)

  File.write(File.join(formula_dir, "release_tag.txt"), release_tag)
  notes = +"Prebuilt bottles of #{formula_name} #{version}. The formula pins each one by sha256.\n\n"
  notes << "| Bottle tag | File | sha256 | Bytes |\n|---|---|---|---|\n"
  formula_bottles["rows"].each do |tag, filename, sha256, bytes|
    notes << "| #{tag} | #{filename} | `#{sha256}` | #{bytes} |\n"
  end
  File.write(File.join(formula_dir, "release_notes.md"), notes)
  puts notes
  list_of_commit_lines << "#{release_tag}: bottles for #{formula_bottles["rows"].map(&:first).sort.join(", ")}"
end

File.write(File.join(bottles_dir, "list_of_formulae.txt"), bottles_by_formula.keys.sort.join("\n") + "\n")
File.write(File.join(bottles_dir, "commit_message.txt"), list_of_commit_lines.join("; ") + "\n")
