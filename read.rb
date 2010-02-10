#!/usr/bin/env ruby

# PostgreSQL table definition:
# create table expenditure ( year int, month int, supplier varchar(255), expense varchar(255), amount int, doctype varchar(255), docno varchar(255), date date );

require 'rubygems'
require 'fastercsv'
require 'pg'

conn = PGconn.connect(:dbname => 'glaexp')

months = {}
%w[january february march april may june july august september october november december].each_with_index do |m,i|
  months[m] = i+1
end

# Data from http://data.london.gov.uk/datastore/package/expenditure-over-£1000
# Converted to UTF-8: for I in *; do iconv -f ISO_8859-1 -t utf-8 $I > ${I}_u; done
# Removed the rubbish preceding and following the main data
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
    values = [year, month, PGconn.escape(supplier), PGconn.escape(expense), iamount, doctype.nil? ? '' : PGconn.escape(doctype), docno.nil? ? '' : PGconn.escape(docno), ddate.nil? ? 'null' : "'#{ddate.to_s}'"]
    conn.exec("INSERT INTO expenditure values (%d, %d, '%s', '%s', %d, '%s', '%s', %s);" % values)
  end
end
