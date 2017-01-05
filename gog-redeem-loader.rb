require "net/http"
require "json"
require "optparse"

@key = nil
@sort_by = :alpha
@search_for = nil
@force = false
@search_mode = :title

def parseOptions
  OptionParser.new do |o|
    o.on("-c", "--code CODE", "Required. Specify your redeem CODE.") {|code| @key = code}
    o.on("-s", "--sortby SORT", "Sort method. Can be alpha, price or rating. Defaults to alpha.") {|sort| @sort_by = sort.to_sym}
    o.on("-n", "--name NAME", "Only print the games with NAME in their title.") {|name| @search_for = name; @search_mode = :title}
    o.on("-f", "--force", "Force loading games from server. Skips cached results.") {|force| @force = force }
    o.on("-h", "--help", "Print this help.") {|h| puts o; exit;}
    o.parse!
  end

  if @key.nil?
    puts "ERRO: You must specify a redeem code."
    exit
  end
end

def loadGames(key)
  games = []
  page = 1
  resume = true

  while (resume) do
    uri = URI("https://www.gog.com/redeem/getProducts/#{key}?page=#{page}")
    response = Net::HTTP.get_response(uri)

    if (response.code == '429')
      puts "INFO: Hit rate limit. Sleeping for 30 seconds..."
      sleep(30)
      next
    elsif (response.code == '200')
      puts "SCCS: Fetched page #{page}"
      games_page = JSON.parse(response.body);
      games_page["products"].each do |game|
        game["page"] = page
        games.push(game)
      end
      page += 1
    elsif (response.code == '403')
      puts "ERRO: Got access denied. Please visit the redeem website once and solve the captcha."
      resume = false
      return nil
    else
      resume = false
    end
  end

  return games
end

def cacheResults(filename, games)
  File.open(filename, "w") do |file|
    file.puts(Marshal.dump(games))
  end
end

def loadCache(filename)
  begin
    data = File.read(filename)
    return Marshal.load(data)
  rescue Exception => e
    puts "Exception #{e.inspect}"
    return nil
  end
end

def printGamesSorted(games, sort_method)
  case (sort_method)
  when :price
    puts "Page \t Price \t\t Name"
    puts games.sort_by{|g| g["title"]}.sort_by{|g| g["price"]["baseAmount"]}.map{|g| "#{g["page"]} \t #{g["price"]["baseAmount"]} #{g["price"]["symbol"]} \t #{g["title"]} \n"}
  when :rating
    puts "Page \t Rating \t Name"
    puts games.sort_by{|g| g["title"]}.sort_by{|g| g["averageReviewScore"]}.map{|g| "#{g["page"]} \t #{g["averageReviewScore"]} \t\t #{g["title"]} \n"}
  else
    puts "Page \t Name"
    puts games.sort_by{|g| g["title"]}.map{|g| "#{g["page"]} \t #{g["title"]} \n"}
  end
end

def printGamesSearch(games, search_string, search_mode)
  # if we add more searches..
  case (search_mode)
  when :title
    games = games.select{|g| g["title"].downcase.include?(search_string.downcase)}
  else
    games = games.select{|g| g["title"].downcase.include?(search_string.downcase)}
  end
  printGamesSorted(games, :alpha)
end

def main
  parseOptions

  games = nil

  # load from cache
  games = loadCache("games.cache-"+@key) unless @force
  loaded_by_cache = true

  # load from server
  if games.nil?
    puts "INFO: Load games from server."
    games = loadGames(@key)
    loaded_by_cache = false
  end

  exit if games.nil?
  cacheResults("games.cache-"+@key, games) unless loaded_by_cache

  # output
  puts "INFO: Results:" unless loaded_by_cache
  unless @search_for.nil?
    printGamesSearch(games, @search_for, @search_mode)
  else
    printGamesSorted(games, @sort_by)
  end
end

main
