
import EventEmitter from 'node:events';
import * as fs from 'node:fs';

export default (() => {
    const base = './localFileStore/'
    const metaPath = `${base}_meta.json`
    if (fs.existsSync(base) === false) {
        fs.mkdirSync(base)
    }
    if (fs.existsSync(metaPath) === false) {
        fs.writeFileSync(metaPath, JSON.stringify({}))
    }
    return {
        file: (filePath: string) => {
            const fullPath = `${base}${filePath}`
            return {
                exists: () => {
                    return [fs.existsSync(fullPath)]
                },
                download: async () => {
                    return [new Uint8Array(fs.readFileSync(fullPath))]
                },
                createWriteStream: () => {
                    return fs.createWriteStream(fullPath)
                },
                createReadStream: () => {
                    return fs.createReadStream(fullPath)
                },
                save: (fileContent: string, meta?: undefined | any) => {
                    if (typeof meta === 'object') {
                        const rawMeta = fs.readFileSync(metaPath);
                        const _meta = JSON.parse(rawMeta.toString())
                        _meta[fullPath] = meta.metadata
                        fs.writeFileSync(metaPath, JSON.stringify(_meta))
                    }
                    fs.writeFileSync(fullPath, fileContent)
                },
                getMetadata: () => {
                    const rawMeta = fs.readFileSync(metaPath);
                    const _meta = JSON.parse(rawMeta.toString())
                    return [_meta[fullPath]]
                }
            }
        }
    }
})();
