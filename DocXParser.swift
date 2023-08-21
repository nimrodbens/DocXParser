//
//  DocXParser.swift
//  TakeOneSDK
//
//  Created by Nimrod Ben Simon on 8/21/23.
//

import ZipArchive

class DocXParser: NSObject, XMLParserDelegate, ObservableObject {
    
    private let recordKey = "w:t"
    private var tempResult = ""
    @Published var result = ""
    
    func readDocX(selectedFile: URL) throws {
        let fm = FileManager.default
        let dataPath = FileUtils.cacheFolder.appendingPathComponent("xml_data")
        try fm.removeItem(at: dataPath)
        try fm.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        SSZipArchive.unzipFile(atPath: selectedFile.path, toDestination: dataPath.path)
        let xmlFileURL = dataPath.appendingPathComponent("word").appendingPathComponent("document.xml")
        getDataFrom(url: xmlFileURL) { [weak self] data, error in
            guard let self else { return }
            if let error {
                print(4747, error.localizedDescription)
                return
            }
            guard let data else { return }
            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
//                print(4747, self.results)
            }
        }
    }
    
    
    private func getDataFrom(url: URL, completion: @escaping (_ data: Data?, _ error: Error?)->()) {
        let session = URLSession(configuration: .default)
        let download = session.dataTask(with: url) { data, response, error in
            completion(data, error)
        }
        download.resume()
    }
}

extension DocXParser {
    func parserDidStartDocument(_ parser: XMLParser) {
        tempResult = ""
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "w:pPr" {
            tempResult += "\n\n"
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "w:br" {
            tempResult += "\n"
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        tempResult += string
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
        tempResult = ""
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if !tempResult.isEmpty {
            result = tempResult
        }
    }
}
