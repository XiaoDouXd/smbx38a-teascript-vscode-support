import { MatchResult } from "./meta-grammar";
import { TeaContext, TeaType, TeaArray } from "./tea-context";

/**
 * 寻找对象类型
 * @param match 匹配结果(对象名)
 * @param context 上下文
 * @returns 对象类型
 */
function getObjectType(match: MatchResult, context: TeaContext): TeaType {
    const reg = /([_a-zA-Z][_a-zA-Z0-9]*)/;
    let name = "";

    if (match.children.length === 2) {
        if (match.children[0].text === ".") {
            const prevIdx = match.parent.children.indexOf(match) - 1;
            const prevMatch = match.parent.children[prevIdx];
            const t = getObjectType(prevMatch, context);
            const name = match.children[1].text;
            const result = reg.exec(name);
            return t.getMember(result[1]).type;
        }
        name = match.children[1].text;
    }
    else {
        name = match.text;
    }
    const result = reg.exec(name);
    return context.getVariable(result[1]).type;

}

export {
    getObjectType
};