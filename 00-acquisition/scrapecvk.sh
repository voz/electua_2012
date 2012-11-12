#!/bin/bash
#
# cvkscrape.sh
# 04.11.2012
# Andrii@Vozniuk.com
# 
# Scrapes cvk.gov.ua
# $1 - defines what should be scrapped: "dilnutsi", "ovk" or "results"
#
# OVK - okrugna vuborcha komisija

what2scrap=$1

# Playing with magical numbers - getting RegionID by OkrugID
function getRegionByOvk()
{
    ovk=$1

    if [ $ovk -ge 1 -a $ovk -le 10 ]; then
        region=1

    elif [ $ovk -ge 11 -a $ovk -le 18 ]; then
        region=5

    elif [ $ovk -ge 19 -a $ovk -le 23 ]; then
        region=7

    elif [ $ovk -ge 24 -a $ovk -le 40 ]; then
         region=12

    elif [ $ovk -ge 41 -a $ovk -le 61 ]; then
         region=14

    elif [ $ovk -ge 62 -a $ovk -le 67 ]; then
         region=18

    elif [ $ovk -ge 68 -a $ovk -le 73 ]; then
         region=21

    elif [ $ovk -ge 74 -a $ovk -le 82 ]; then
         region=23

    elif [ $ovk -ge 83 -a $ovk -le 89 ]; then
         region=26

    elif [ $ovk -ge 90 -a $ovk -le 98 ]; then
         region=32

    elif [ $ovk -ge 99 -a $ovk -le 103 ]; then
         region=35

    elif [ $ovk -ge 104 -a $ovk -le 114 ]; then
         region=44

    elif [ $ovk -ge 115 -a $ovk -le 126 ]; then
         region=46

    elif [ $ovk -ge 127 -a $ovk -le 132 ]; then
         region=48

    elif [ $ovk -ge 133 -a $ovk -le 143 ]; then
         region=51

    elif [ $ovk -ge 144 -a $ovk -le 151 ]; then
         region=53

    elif [ $ovk -ge 152 -a $ovk -le 156 ]; then
         region=56

    elif [ $ovk -ge 157 -a $ovk -le 162 ]; then
         region=59

    elif [ $ovk -ge 163 -a $ovk -le 167 ]; then
         region=61

    elif [ $ovk -ge 168 -a $ovk -le 181 ]; then
         region=63

    elif [ $ovk -ge 182 -a $ovk -le 186 ]; then
         region=65

    elif [ $ovk -ge 187 -a $ovk -le 193 ]; then
         region=68

    elif [ $ovk -ge 194 -a $ovk -le 200 ]; then
         region=71

    elif [ $ovk -ge 201 -a $ovk -le 204 ]; then
         region=73

    elif [ $ovk -ge 205 -a $ovk -le 210 ]; then
         region=74

    elif [ $ovk -ge 211 -a $ovk -le 223 ]; then
         region=80

    elif [ $ovk -ge 224 -a $ovk -le 225 ]; then
         region=85

    else
        echo "Error: invalid dilnitsia number"
        echo ""
        exit
    fi
}


echo "Scraping "$what2scrap" from cvk.gov.ua"

# TODO: Rewrite using a case statement
# TODO: Create a template here and perform a substitution in the loop below
if [ $what2scrap = "dilnutsi" ]; then
    # http://www.cvk.gov.ua/vnd2012/wp029pt001f01=900pid100=%OVK%pf7331=%DILNUTSIA%.html
    address="http://www.cvk.gov.ua/vnd2012/wp029pt001f01=900pid100="

    #Extracting all dilnutsia columns with html tags
    query="//*[@id='content']/table[4]/tbody/tr[position()>1]"

    #Extracting location column
    # query="//*[@id='content']/table[4]/tbody/tr[position()>1]/td[2]/text()"

    #Extracting location address line
    # query="//*[@id='content']/table[4]/tbody/tr[position()>1]/td[2]/br/following-sibling::text()"

elif [ $what2scrap = "ovk" ]; then
    # http://www.cvk.gov.ua/vnd2012/wp024pt001f01=900pid100=1pf7331=%OVK%.html
    address="http://www.cvk.gov.ua/vnd2012/wp024pt001f01=900pid100="
    query="//*[@id='content']/table[4]/tbody/tr[position()>0]"

elif [ $what2scrap = "results" ]; then
    address="http://www.cvk.gov.ua/vnd2012/wp336pt001f01=900pf7331="
    query="//*[@id='restab']/table/tr[position()>1]"

else
    echo "Error: What should I scrape?"
    echo "Possibilities: dilnutsi, ovk, results"
    echo ""
    exit
fi

echo "Scraping: "$what2scrap

now=$(date +"%Y_%m_%d")
outfile=$what2scrap"_"$now".html"
echo "Writing to: "$outfile

# TODO: distribute in xml, json, tsv and litesql

for ovk in {1..225}
do

    if [ $what2scrap = "results" ]; then
        curaddr=$address$ovk".html"
        echo $curaddr

        wget -O - \
             --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4'\
             --wait=10 \
             --random-wait \
             --header "Referer: www.cvk.gov.ua/" $curaddr | \
        iconv -f cp1251 -t utf-8 | \
        tidy -quiet -m -utf8 | \
        sed 's/&nbsp;//g' | \
        xpath $query | \
        sed 's/<td class="td3small" align="center"><b>//g' | \
        sed 's/<td class="td2">//g' | \
        sed 's/<td class="td2" align="center">//g' | \
        sed 's/<span style="color:maroon">//g' | \
        sed 's/<\/b>//g' | \
        sed 's/<\/span>//g' | \
        tr '\n' ' ' | \
        sed "s/<\/td> <\/tr><tr> />$ovk\\`echo '\t'`/g" | \
        sed "s/<tr> /$ovk\\`echo '\t'`/g" | \
        sed 's/<\/td> <\/tr>//g' | \
        sed "s/<\/td> /\\`echo '\t'`/g" | \
        tr '>' '\n' >> $outfile

    elif [ $what2scrap = "dilnutsi" ]; then
        getRegionByOvk $ovk
        curaddr=$address$region"pf7331="$ovk".html"
        echo $curaddr

        wget -O - \
             --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4'\
             --wait=10 \
             --random-wait \
             --header "Referer: www.cvk.gov.ua/" $curaddr | \
        iconv -f cp1251 -t utf-8 | \
        tidy -quiet -m -utf8 | \
        sed 's/&nbsp;//g' | \
        # sed "s/<\/b>/\\`echo '\n<\/b>'`/g" | \
        # sed "s/<\/td>/\\`echo '\n<\/td>'`/g" | \
        # sed "s/<\/br>/\\`echo '\t'`/g" | \
        xpath $query | \
        sed "s/<b>/$ovk\\`echo '\t'`/g" | \
        sed 's/<td align="center" class="td3">//g' | \
        sed 's/<td class="td2">//g' | \
        sed "s/<br \/>/<TAB>/g" | \
        sed "s/<\/b><\/td>/<TAB>/g" | \
        tr '\n' ' ' | \
        sed "s/<\/td> <\/tr><tr> />/g" | \
        sed "s/<\/td> <\/tr> //g" | \
        sed "s/<tr> //g" | \
        sed "s/<\/td>/<TAB>/g" | \
        sed "s/<TAB> /\\`echo '\t'`/g" | \
        tr '>' '\n' >> $outfile

    elif [ $what2scrap = "ovk" ]; then
        getRegionByOvk $ovk
        curaddr=$address$region"pf7331="$ovk".html"
        echo $curaddr

        wget -O - \
             --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4'\
             --wait=10 \
             --random-wait \
             --header "Referer: www.cvk.gov.ua/" $curaddr | \
        iconv -f cp1251 -t utf-8 | \
        tidy -quiet -m -utf8 | \
        sed 's/&nbsp;//g' | \
        xpath $query | \
        sed '/<td class="td10">/d' | \
        sed '/<td width="50%" class="td10">/d' | \
        sed '/<\/tr><tr>/d' | \
        sed 's/<\/td>//g' | \
        sed 's/<td class="td2">/<TAB>/g' | \
        tr '\n' ' ' | \
        sed 's/<tr> <td width="50%" class="td2">/<BEGIN>/g' | \
        sed "s/<BEGIN>/$ovk\\`echo '\t'`/g" | \
        sed 's/<\/b>//g' | \
        sed "s/ <TAB>/\\`echo '\t'`/g" | \
        sed 's/<b>//g' | \
        sed 's/ <\/tr> //g' >> $outfile

    fi

    sleep 8s
done
