# Handshake Data

This is a guide for retrieving Spec's Handshake data.

We store Handshake data in a MongoDB database deployed on the cloud with MongoDB Atlas. Right now, there is one database, `lionshare`, with one collection, `postings`. `postings` is an array of all job postings that existed from February 8, 2020 to March 29, 2020. (Archives exist since September, I am working on getting those up.)

## Prerequisites

1. Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

2. Make a [GitHub](https://github.com) account. Ask Jason, Charlotte, or Raeedah to add you to the `spec-journalism` organization.

3. To be able to write to our repositories, set up an SSH key. Follow the instructions in the first five sections of [Connecting to GitHub with SSH](https://help.github.com/en/articles/connecting-to-github-with-ssh).

4. Install Python 3.7 or greater.

5. Install [Pipenv](https://pipenv.pypa.io/en/latest/). 

## Setup

1. Clone the repository and move into it:
```
$ git clone git@github.com:spec-journalism/handshake-data.git`
$ cd handshake-data
```

2. Create a `.env` file with the contents below. (See this [Google Doc](https://docs.google.com/document/d/1C6WPRpabD6YXjQK3VnvjGy02fgxaARHbJTirm3Rzf8I/edit) for the MongoDB user credentials.) Make sure `.env` is always listed in your [`.gitignore`](https://guide.freecodecamp.org/git/gitignore/) file.
<pre>
# MongoDB credentials
MDB_USERNAME=<var>USERNAME</var>
MDB_PASSWORD=<var>PASSWORD</var>
</pre>

3. Run `pipenv install` to install the necessary packages.

4. Run `pipenv shell` to launch the virtual environment and get access to those packages and the `.env` environment variables.

## Samples

**Python:** The `sample.py` script has skeleton code with comments that should help you access the postings data.
