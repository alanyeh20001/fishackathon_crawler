require 'open-uri'
require 'nokogiri'
require 'csv'
=begin

data: {
  email: "",
  phone: "",
  website: "",
  name: "",
  fip_stage: "",
  gear_types: [],
  fishing_area: "",
  species: "",
  organization_name: "",
  overview: ""
}

=end

$domain = "https://fisheryprogress.org"
$store_path = "/Users/alanyeh/Documents/fishackathon_crawler_v2.csv"

def fip_crawl
  index_url = "#{$domain}/directory/prospective"

  queue = fetch_paths(index_url)

  CSV.open($store_path, "a") do |csv|
    csv << ["name", "email", "phone", "website", "fip_stage", "gear_types", "overview", "organization_name", "species", "fishing_area"]
  end

  queue.each do |q|
    puts q

    doc = Nokogiri::HTML(open(URI($domain + q)))
    overview = doc.css('.fip-description-full p').text
    fip_stage = doc.css('.content .content-first .field--name-field-fip-stage .field__item').text
    species = doc.css('.field--name-field-species-common .content .field--name-field-species .field__item').text
    gear_types = doc.css('.field--name-field-gear-type .field__item').map(&:text).join(",")
    fishing_area = doc.css('.field--name-field-fao-major-fishing-area .field__item').text
    organization_name = doc.css('.field--name-field-organization-name .field__item').text
    email = doc.css('.field--name-field-email .field__item').text
    website = doc.css('.field--name-field-website .field__item a').attr('href')
    name = doc.css('.field--name-field-contact-name .field__item').text
    phone = doc.css('.field--name-field-phone .field__item').text

    fishing_area = filter_area(fishing_area)

    CSV.open($store_path, "a") do |csv|
      csv << [name, email, phone, website, fip_stage, gear_types, overview, organization_name, species, fishing_area]
    end
  end
end

def fetch_paths(url)
  doc = Nokogiri::HTML(open(URI(url)))
  doc.css('div.view-content div.views-field a').map { |item| item.attr('href') }
end

def filter_area(fishing_area)
  regex = /Area (\d+)/
  fishing_area.scan(regex).map { |area| area[0] }.join(",")
end

fip_crawl
