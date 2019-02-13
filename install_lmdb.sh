SOURCE_DIR=`pwd`
LMDB_DIR_URL="https://github.com/LMDB/lmdb.git"
LMDB_DIR_PATH="$SOURCE_DIR/lmdb/Sources"

echo "============================ LMDB ============================"
echo "Cloning lmdb from - $LMDB_DIR_URL"
git clone $LMDB_DIR_URL $LMDB_DIR_PATH
cd $LMDB_DIR_PATH
git checkout b9495245b4b96ad6698849e1c1c816c346f27c3c
cd $SOURCE_DIR