/** Documentation
 *
 *
 * */

// [1] Back-end fxns /// ############################################
function pr(msg) {  // Print to console quickly
    console.log(msg)
}
function opFmat(mat, which) { // fmat= @(mat, index)mat(index);
    return mat[which]
}
function opLinspace(minval, maxval, n) {  // min and max vals must be integers
    var arr=[],
        space=  (maxval - minval)/n;
    for (var  i=0; i < n; i++) {
        arr.push(minval+i*space)
    }
    return arr
}
function opLinFromTo(start,end, step) {
    var vec=[];
    for  (var  i=start; i< end+1; i+=step) {
        vec.push(i)
    }
    return vec;
}
function opVecRepmat(arr, n) {  // Repmat (1D vector-level only)
    var vec =[];
    for (var i= 0; i< n; i++) {
        vec = vec.concat(arr)
    }
    return vec;
}
function opNumFindInd(arr, match) { // find(x(:)==y) - numerical only at this point
    var ind=[];
    for (var i= 0; i < arr.length; i++) {
        if (arr[i]==match) {
            ind.push(i);
        }
    }
    return ind;
}
function opIndexReadVec(arr, indices) {  // arr(indices)
    var arrout = [];
    for(var i = 0; i < indices.length; i++) {
        arrout.push(arr[indices[i]]);
    }
    return arrout;
}
function opIndexWriteVec(arr, indices, inputs) {  // arr(indices)= input
    if (inputs.length != indices.length) {throw 'ERROR in opIndexWriteVec: length(indices) ~= length(inputs)'}
    for(var i = 0; i < indices.length; i++) {
        arr[indices[i]] = inputs[i];
    }
    return arr
}
function opStartStopReadVec(arrin, first, last) { // Fetch elements of array
    var arr=[];
    for(var i = first; i < last+1; i++) {
        arr.push(arrin[i])
    }
    return arr
}
function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;

    // While there remain elements to shuffle...
    while (0 !== currentIndex) {

        // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;

        // And swap it with the current element.
        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
    }

    return array
};
function opMean(array) {
    return array.reduce(function(a, b) { return a + b; })/array.length
}
function opMax( array ){
    return Math.max.apply( Math, array );
};
function opGetQueryParams(qs) {
    qs = qs.split('+').join(' ');

    var params = {},
        tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;
    while (tokens = re.exec(qs)) {
        params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
    }
    return params;
}
function opGetRT(StartMinSec, KeyMinSec) {
    var ms = KeyMinSec.getMilliseconds() - StartMinSec.getMilliseconds();
    var sec = KeyMinSec.getSeconds() - StartMinSec.getSeconds();
    var min = KeyMinSec.getMinutes()-StartMinSec.getMinutes();
    if (ms<0) { ms=ms+1000;}
    if (sec<0) {sec=sec+60;}
    if (min<0) {min=min+60;}
    return min*60*1000 + sec*1000 + ms;   // Return RT in ms
}


// [2] Global design settings  /// ############################################
var log = {   // Design settings

    TestNull:document.location.href.substr(document.location.href.indexOf('CIS_v'), document.location.href.length).substr(0, document.location.href.substr(document.location.href.indexOf('CIS_v'), document.location.href.length).indexOf('/acq')),
    TaskVersion:document.location.href.substr(document.location.href.indexOf('CIS_v'), document.location.href.length).substr(0, document.location.href.substr(document.location.href.indexOf('CIS_v'), document.location.href.length).indexOf('/h')),
    RewardMag: 100,

    // Design
    sub_pCorrect: 0.5,
    src_pCorrect: [0.55, 0.95],  // Accuracies given (dis)agree
    pCorrect: [],                // Assigned later

    // Sources
    Src: {
        condition: ['C','D','N','I'],
        stim_options: ['bird','cat', 'elephant','fish','peacock', 'fox', 'butterfly', 'dolphin'],
        size: 300,  // pxs, assume square
        key: {
            b: 'bird',
            c: 'cat',
            e: 'elephant',
            f: 'fish'
        }
    },

    // Stimuli settings
    Stim: {
        q: 'Is this a blap?',
        maxno: 768,    // Max no. stim in stimset
        size: [300, 300],
        time: 1000,
        masktime: 1000
    },

    // Keyboard numbers
    key: {
        up: 38,
        down: 40,
        left: 37,
        right:39,
        k1: 49,     // 1 (top)
        k2: 50,     // 2
        k3: 51,     // 3
        k4: 52,     // 4
        yes: 38, // Stim yes = Up
        no: 40 // Stim yes = No
    }
};

// Set accuracies of sources
log.pCorrect= {             // Accuracy when wrong, correct
    C: log.src_pCorrect,
    D: [log.src_pCorrect[1], log.src_pCorrect[0]],
    N: [opMean(log.src_pCorrect), opMean(log.src_pCorrect)],
    I: [0.5, 0.5]
};

// Other logistics
var marknext= "@#@",
    markname = "@@nm",
    markeq= "@@=",
    markend= "@##@";