if [[ $1 =~ ^[0-9]+$ ]]
then
  CONDITION="e.atomic_number=$1"
else
  CONDITION="e.symbol='$1' OR e.name='$1'"
fi

ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p USING(atomic_number) JOIN types t USING(type_id) WHERE $CONDITION")

if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
  exit
fi

IFS='|' read NUM NAME SYMBOL TYPE MASS MELT BOIL <<< "$ELEMENT"
echo "The element with atomic number $NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
