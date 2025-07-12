#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <array>
#include <algorithm>
#include <cstdlib>
using namespace std;

struct TrieNode {
    bool isEnd = false;
    array<TrieNode*, 26> children = {};
};

class Trie {
public:
    TrieNode* root = new TrieNode();

    void insert(const string& word) {
        TrieNode* node = root;
        for (char c : word) {
            if (!isalpha(c)) continue;
            c = tolower(c);
            int index = c - 'a';
            if (!node->children[index]) node->children[index] = new TrieNode();
            node = node->children[index];
        }
        node->isEnd = true;
    }

    void dfs(TrieNode* node, string prefix, vector<string>& result) {
        if (result.size() >= 10) return;
        if (node->isEnd) result.push_back(prefix);
        for (int i = 0; i < 26; ++i) {
            if (node->children[i])
                dfs(node->children[i], prefix + char(i + 'a'), result);
        }
    }

    vector<string> suggest(const string& prefix) {
        TrieNode* node = root;
        for (char c : prefix) {
            if (!isalpha(c)) return {};
            c = tolower(c);
            int index = c - 'a';
            if (!node->children[index]) return {};
            node = node->children[index];
        }
        vector<string> res;
        dfs(node, prefix, res);
        return res;
    }
};

Trie trie;

void loadWordsFromFile(const string& filename) {
    ifstream file(filename);
    string word;
    while (getline(file, word)) {
        trie.insert(word);
    }
    file.close();
}

string getQuery() {
    string query = getenv("QUERY_STRING");
    size_t pos = query.find("q=");
    if (pos != string::npos) return query.substr(pos + 2);
    return "";
}

int main() {
    cout << "Content-type: application/json\n\n";

    loadWordsFromFile("words.txt");

    string prefix = getQuery();
    vector<string> suggestions = trie.suggest(prefix);

    cout << "[";
    for (size_t i = 0; i < suggestions.size(); ++i) {
        cout << "\"" << suggestions[i] << "\"";
        if (i != suggestions.size() - 1) cout << ",";
    }
    cout << "]";
    return 0;
}
