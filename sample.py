from pymongo import MongoClient
from pprint import pprint
import os

# Retrieve .env environment variables
MDB_USERNAME = os.getenv('MDB_USERNAME');
MDB_PASSWORD = os.getenv('MDB_PASSWORD');
MDB_URI = f'mongodb+srv://{MDB_USERNAME}:{MDB_PASSWORD}@lionshare-7nhlo.mongodb.net/test?retryWrites=true&w=majority'

def main():
    """Shows basic retrieval and filtering of postings.
    """

    client = MongoClient(MDB_URI) # Connect to mongo instance
    db = client.archive # Get archive database (contains all postings since September)
    postings = db.postings # Get postings collection

    # Counts and prints total postings
    print(f'There are {postings.count_documents({})} postings in total.')

    the_filter = { 'employer_name': 'Columbia University' }
    print(f'There are {postings.count_documents(the_filter)} postings from Columbia University.')

    # A collection's find method returns a cursor, which is like an iterator,
    # not an actual list. See:
    # https://api.mongodb.com/python/current/tutorial.html#querying-for-more-than-one-document
    for columbia_posting in postings.find(the_filter):
        print('Example posting:')
        pprint(columbia_posting)
        break

if __name__ == '__main__':
    main()
