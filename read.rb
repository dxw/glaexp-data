#!/usr/bin/env ruby

require 'rubygems'
require 'fastercsv'

months = {}
%w[january february march april may june july august september october november december].each_with_index do |m,i|
  months[m] = i+1
end

# Data from http://data.london.gov.uk/datastore/package/expenditure-over-£1000
# Converted to UTF-8: for I in *; do iconv -f ISO_8859-1 -t utf-8 $I > ${I}_u; done
Dir['data/*.csv_u'].each do |f|
  f.match(/(\w+)_(\d{4})/)

  month = months[$1]
  year = $2.to_i

  FasterCSV.foreach(f) do |row|
    #,Supplier,Expense Description,Amount,Doc Type,Doc No,Date
    row.shift if row[0] == nil
    supplier, expense, amount, doctype, docno, date = row
    unless date.nil?
      date.match(%r[(\d{2})/(\d{2})/(\d{4})])
      ddate = Date.new($3.to_i, $2.to_i, $1.to_i)
    else
      ddate = nil
    end
    famount = amount.gsub(/[,\(\)]/,'').to_f
    iamount = (famount*100).to_i
    p [year, month, supplier, expense, iamount, doctype, docno, ddate]
  end
end
