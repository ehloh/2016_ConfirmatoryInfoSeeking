/**
 * Acquisition script for CIS: Session 4 (Rating)
 */

// [1] Set up session  ########################################
var DeveloperMode=0,            // Am I debugging?
    DeveloperAutoChoice= 1,     // Automatically generate choices
    DeveloperSpeedUp=1 ,        // Simulated decision time in seconds (delay for auto choice)
    DeveloperMsg=1;
{
    //if (DeveloperMode==1) { console.log('URL pars manually added '); var urladd='?worker_id=HC_wid&assignment_aid=HC_aid&hit_id=HC_hid&srcstim=%22[%27bird%27,%27cat%27,%27elephant%27,%27fish%27]%22';   window.history.pushState({'page_id': 1, 'user_id': 5}, 'blah', 'h3_Choose.html' + urladd); }
     var query = opGetQueryParams(document.location.search);
} // Inputs for script running during setup

// [2] Set up session  ########################################
{
    if (DeveloperMode == 0) { DeveloperAutoChoice = 0; DeveloperMsg = 0; DeveloperSpeedUp = 0; }
    // Rating this source (ds)
    log.ratesrc_qs = {   // attribute: [0] full question, [1] Scale 1 value, [2] Scale 10 value
        competent:  ["How competent was this player at figuring out if each object was a blap?",
            "Very bad, this player was just guessing", "Very good, this player always knew the right answer"],
        similar:    ["How similar was this player's choices to your own guesses about whether each object was a blap?",
            "Very dissimilar", "Very similar"],
        suspicious: ["How suspicious were you that this player knew the correct answer but was trying to trick you into making the incorrect choice?",
            "Not at all suspicious/I was very confident that this player was giving me its best advice", "Very suspicious of this player/thought this player was trying to trick me into doing badly"],
        like:       ["How much do you like this player, based on the decisions that it has made in the experiment?",
            "Very much dislike", "Very much like"],
        trust:      ["Imagine a trial in which we do NOT show you the object. Instead, we only show the object to this player, and this player tells you whether it thinks the object is a blap or not. How much would you trust this player's decision and make your final choice according to what this player said?",
            "Very much distrust/I would just guess on my own", "Very much trust/I would make the same choice as this player"],
        predictable:["If we showed you 10 new objects that you have never seen before, how good do you think you would be at predicting what this player would say (about whether an object was a blap or not)?",
            "Very bad at predicting this player's choice", "Very good at predicting this player's choice"],
        opposite:   ["How useful do you think it would be to do the opposite of what this player recommends that you do on each trial?",
            "This would be a very bad strategy", "This would be a very good strategy"],
        useful:     ["How useful did you find this player's choices to be in helping you make final decisions about whether each object was a blap?",
            "Not useful at all/I do as well with this player's opinion compared to doing it by myself", "Very useful/I do much better with this player's opinion relative to doing the task on my own"],
        confident:  ["How confident are you in your judgment of this player's accuracy?", "Extremely unconfident/ I don't know how accurate this player is",
            "Extremely confident/ I know exactly how accurate this player is"]
    };

    // Rating self (dp)
    log.rateself_qs = {   // attribute: [0] full question, [1] Scale 1 value, [2] Scale 10 value
        task:           ["How good do you think you were at figuring out if the objects were blaps (without anybody's help)?",
                            "Very bad at the task", "Very good at the task"],
        task_relative:  ["How good do you think you were at figuring out if the objects were blaps (without anybody's help), compared to other people?",
                            "Very much worse than most people", "Very much better than most people"],
        overall:        ["How well do you think you did on the task, overall (both in judging the objects yourself, and in using the info from the other players)?",
                            "I did extremely badly", "I did extremely well"],
        sourcelearn:    ["How good do you think you were at figuring out how good the other players were?",
                            "Very bad at figuring this out",  "Very good at figuring this out"]
    };

    // Debrief Qs (free response)  <-- Think I should put this in Google Dox
    log.debrief_link = 'https://goo.gl/forms/ftixx5oImwmKAyD73';

    // Other impt settings
    log.srcstim = JSON.parse(query.srcstim);
    log.src_ntrials =  Object.keys(log.ratesrc_qs).length*4;
    log.self_ntrials = Object.keys(log.rateself_qs).length;
    log.ratesrc_qkey =  Object.keys(log.ratesrc_qs);
    log.rateself_qkey = Object.keys(log.rateself_qs);

    // Logistics
    log.ratekey =  {
        k1: 49,   // 1 (top)
        k2: 50,   // 2
        k3: 51,   // 3
        k4: 52,   // 4
        k5: 53,   // 5
        k6: 54,   // 6
        k7: 55,   // 7
        k8: 56,   // 8
        k9: 57,   // 9
        k10: 48   // 0 key = value 10
            };
    var keymap={};
    for(var k in log.ratekey) { // Reverse keymap for fetching responses
        keymap[log.ratekey[k]] = parseInt(k.substring(1,3));
    }
    log.job = {
        hit_id: query.hit_id,
        worker_id: query.worker_id,
        assignment_id: query.assignment_id,
        DeveloperMode: DeveloperMode,
        Session: 'Rate',
        timestamp: {}
    };

} // Design settings
{
    // Source rating questions setup
    var ds_q   =    new Array(log.src_ntrials).fill(999),
        ds_src =    new Array(log.src_ntrials).fill(999),
        ds_rating = new Array(log.src_ntrials).fill(999),
        ds_rt =     new Array(log.src_ntrials).fill(999),
        qcolors = ['#ffb039', '#ff9886', '#8b816c', '#309245', '#6061ff', '#5cdc67', '#C5CF3F', '#B82AB8', '#38B2B8', '#806bb8'], // Colors for question
        ws = {},
        tn_src =0;
    ws.qorder = shuffle(opLinFromTo(1, log.src_ntrials/4, 1));
    if (DeveloperMode) { ws.qorder =  opLinFromTo(1, log.src_ntrials/4, 1); pr('Q shuffle turned off for debugging')}
    for (var  i=0; i < log.src_ntrials/4; i++) {
        ds_q = opIndexWriteVec(ds_q, opLinFromTo((i)*4, (i+1)*4-1,1), opVecRepmat(ws.qorder[i], 4));
        ds_src = opIndexWriteVec(ds_src, opLinFromTo((i)*4, (i+1)*4-1,1), shuffle([1,2,3,4]));
    }

    // Self-rating questions setup
    var dp_q = shuffle(opLinspace(1, log.self_ntrials+1, log.self_ntrials)),
        dp_rating = new Array(log.self_ntrials).fill(999),
        dp_rt =     new Array(log.self_ntrials).fill(999),
        wp = {},
        tn_self =0;
} // Session settings

// [3] Event functions ########################################
function presRateSrc() {
    $('.Rate_qtext').hide();  // Flicker
    $('.RateSrc_sourcepic').hide();

    // Set up this question
    ws.q = log.ratesrc_qs[log.ratesrc_qkey[ds_q[tn_src]-1]][0];
    ws.v1 = log.ratesrc_qs[log.ratesrc_qkey[ds_q[tn_src]-1]][1];
    ws.v2 = log.ratesrc_qs[log.ratesrc_qkey[ds_q[tn_src]-1]][2];
    ws.src_cmd = '<img src="Stim/src_' + log.srcstim[ds_src[tn_src]-1] + '_small.png" height="200px" width="200px" alt=' + log.srcstim[ds_src[tn_src]-1] + '>';
    setTimeout(function() {
        $('.RateSrc_sourcepic').html(ws.src_cmd)
            .css({'top': '45%', 'left': '50%', 'position': 'fixed', 'transform': 'translate(-50%, -50%)'})
            .show();
        $('.Rate_qtext').html(ws.q)
            .css({'background-color': qcolors[Math.ceil((tn_src+1)/4) -1],
                'display':'flex', 'justify-content':'center','align-items':'center'
             })
            .show();
    },  300);
    $(".Rate_anskey1").text('1 = '  + ws.v1).show();
    $(".Rate_anskey10").text('10  = ' + ws.v2).show();
    $(".Rate_scale").show();

    console.log( '[' + tn_src.toString() + '] Src: ' +  log.ratesrc_qkey[ds_q[tn_src]-1]);

    // Record response
    if (DeveloperAutoChoice) {
        ds_rating[tn_src] = Math.round(Math.random()*10);
        ds_rt[tn_src] = tn_src;

        if (DeveloperSpeedUp) { ws.waifakekey =1} else {ws.waifakekey =2000}
        setTimeout(function() {  // Artificial delay for simulation

            // COPIED FROM BELOW  ##########
            if (tn_src < ds_rating.length-1) {  // More Rate-Src trials
                tn_src ++; ws = {};
                presRateSrc()
            }
            else {                      // Progress to Rate-Self trials
                $('.wrap_Rate').hide();
                $(".Rate_qtext").html(' ');
                $(".Rate_anskey1").html(' ');
                $(".Rate_anskey10").html(' ');
                $(".RateSrc_sourcepic").html(' ').hide();

                // Instructions for self-ratings Qs
                $('.StartEnd_text').html("Thank you!<br><br>" +
                        "Next, We'd like to know more about how you think YOU did on the task. <br><br>" +
                        "You'll be asked a few questions, and you should respond to each one by choosing a number from the scale of 1 to 10. <br><br>" +
                        "Like before, use the number keys on your keyboard to make your response (using the 0 key for a '10' response)<br><br>" +
                        "The computer will always tell you what the 1 and 10 options on the scale indicate, " +
                        "but you should choose whichever number on the scale best reflects how you feel<br><br><br><b>" +
                        "Press any key to continue</b>")
                    .css({'top': '20%', 'font-size': '18pt'}).show();
                setTimeout(function() {

                    presRateSelf();
                    $('.StartEnd_text').hide();
                    $('.wrap_Rate').show();
                },  DeveloperSpeedUp*1000);
            }
        }, ws.waifakekey);
    }
    else {
        ws.ask_start = new Date();
        $(document).on('keydown.asksrc', function (event) {
            ws.ask_keydown = new Date();

            if (event.keyCode> 47.5 && event.keyCode < 57.5) {    // Acceptable keyboard response
                $(document).off('keydown.asksrc');

                switch (event.keyCode) {
                    case 49:
                        ws.sc = 1;
                        break;
                    case 50:
                        ws.sc = 2;
                        break;
                    case 51:
                        ws.sc = 3;
                        break;
                    case 52:
                        ws.sc = 4;
                        break;
                    case 53:
                        ws.sc = 5;
                        break;
                    case 54:
                        ws.sc = 6;
                        break;
                    case 55:
                        ws.sc = 7;
                        break;
                    case 56:
                        ws.sc = 8;
                        break;
                    case 57:
                        ws.sc = 9;
                        break;
                    case 48:
                        ws.sc = 10;
                        break;
                }
                ds_rating[tn_src] = ws.sc;
                ds_rt[tn_src] = opGetRT(ws.ask_start, ws.ask_keydown);
                console.log(ds_rating[tn_src])


                // What next?
                if (tn_src < ds_rating.length-1) {  // More Rate-Src trials
                    tn_src ++; ws = {};
                    presRateSrc()
                }
                else {                      // Progress to Rate-Self trials
                    $('.wrap_Rate').hide();
                    $(".Rate_qtext").html(' ');
                    $(".Rate_anskey1").html(' ');
                    $(".Rate_anskey10").html(' ');
                    $(".RateSrc_sourcepic").html(' ').hide();

                    // Instructions for self-ratings Qs
                    $('.StartEnd_text').html("Thank you!<br><br>" +
                            "Next, We'd like to know more about how you think YOU did on the task. <br><br>" +
                            "You'll be asked a few questions, and you should respond to each one by choosing a number from the scale of 1 to 10. <br><br>" +
                            "Like before, use the number keys on your keyboard to make your response (using the 0 key for a '10' response)<br><br>" +
                            "The computer will always tell you what the 1 and 10 options on the scale indicate, " +
                            "but you should choose whichever number on the scale best reflects how you feel<br><br><br><b>" +
                            "Press any key to continue</b>")
                        .css({'top': '20%', 'font-size': '18pt'}).show();
                    $(document).on('keydown.continue', function (event) {  // Keypress to start
                        $(document).off('keydown.continue');
                        presRateSelf();
                        $('.StartEnd_text').hide();
                        $('.wrap_Rate').show();
                    })
                }
            }
        });
    }
}
function presRateSelf() {
    $('.Rate_qtext').hide();
    $(".Rate_anskey1").hide();
    $(".Rate_anskey10").hide();

    wp.ask_start = new Date();
    wp.q    = log.rateself_qs[log.rateself_qkey[dp_q[tn_self]-1]][0]; 
    wp.v1   = log.rateself_qs[log.rateself_qkey[dp_q[tn_self]-1]][1];
    wp.v2   = log.rateself_qs[log.rateself_qkey[dp_q[tn_self]-1]][2];
    setTimeout(function() {
        $('.Rate_qtext').text(wp.q)
             .css({'background-color': '#A6ABA6', 'left': '50%', 'transform': 'translate(-50%, -50%)'}).show();
        $(".Rate_anskey1").text('1 = '  + wp.v1).show();
        $(".Rate_anskey10").text('10  = ' + wp.v2).show();
    },  300);
    console.log( '[' + tn_self.toString() + '] Self: ' +  log.rateself_qkey[ds_q[tn_self]-1]);

    if (DeveloperAutoChoice) {
        dp_rating[tn_self] =  Math.round(Math.random()*10);
        dp_rt[tn_self] = tn_src;

        if (DeveloperSpeedUp) { wp.waifakekey =1} else {wp.waifakekey =2500}
        setTimeout(function() { // Artificial delay for simulation

        // COPIED FROM BELOW #############
        if (tn_self < log.self_ntrials - 1) {
            tn_self++;
            wp = {};
            presRateSelf()
        }
        else {
            opPostData()
        }
        }, wp.waifakekey);
    }
    else {
        // Record response
        $(document).on('keydown.askself', function (event) {
            wp.ask_keydown = new Date();
            if (event.keyCode> 47.5 && event.keyCode < 57.5) {    // Acceptable keyboard response
                $(document).off('keydown.askself');
                switch (event.keyCode) {
                    case 49:
                        wp.sc = 1;
                        break;
                    case 50:
                        wp.sc = 2;
                        break;
                    case 51:
                        wp.sc = 3;
                        break;
                    case 52:
                        wp.sc = 4;
                        break;
                    case 53:
                        wp.sc = 5;
                        break;
                    case 54:
                        wp.sc = 6;
                        break;
                    case 55:
                        wp.sc = 7;
                        break;
                    case 56:
                        wp.sc = 8;
                        break;
                    case 57:
                        wp.sc = 9;
                        break;
                    case 48:
                        wp.sc = 10;
                        break;
                }
                dp_rating[tn_self] = wp.sc;
                dp_rt[tn_self] = opGetRT(wp.ask_start, wp.ask_keydown);
                console.log(dp_rating[tn_self])

                // Get on with it
                if (tn_self < log.self_ntrials - 1) {
                    tn_self++;
                    wp = {};
                    presRateSelf()
                }
                else {
                    opPostData()
                }
            }
        });
    }
}
function presTrialStatsPrint(which) { // Input: 1=Start, 2=End
    if (DeveloperMode==1) {
        switch (which) {
            case 1: // Start
                $(".DevMsgStart").html("Qs: " + log.s4.qs[d_qs[tn]-1] + '<br> Sources: ' + log.InfoColor[d_sourceL[tn]-1] + "       &         " + log.InfoColor[d_sourceR[tn]-1] ).show();
                break;
            case 2:  // End
                $(".DevMsgEnd").html("Qs: " + log.s4.qs[d_qs[tn]-1] + '<br> Sources: ' + log.InfoColor[d_sourceL[tn]-1] + "       &         " + log.InfoColor[d_sourceR[tn]-1] + "<br><br> Chose: " + log.InfoColor[d_ch[tn]-1] ).show();
                break;
        }
    }
}
function opPostData(){
    $('.wrap_Rate').hide();
    log.job.timestamp.end = new Date();
    log.job.payscore  = Math.round(Math.random()*100);
    log.job.completecode ="cis" + String(log.TaskVersion.match(/[0-9]/g)[0]) + String(log.TaskVersion.match(/[0-9]/g)[1]) + '_' + String( Math.floor((Math.random() * 200000)) + "_p" + log.job.payscore.toString() );
    console.log("TIME TAKEN:  " + String(log.job.timestamp.end.getHours()-log.job.timestamp.start.getHours()) + " hrs " + String(log.job.timestamp.end.getMinutes()- log.job.timestamp.start.getMinutes()) + " minutes");

    // Post to Server
    var postdata= markname + "subject" + markeq + log.job.worker_id + marknext
        + markname + "session" + markeq + "3Rate" + marknext
        + markname + "log" + markeq + JSON.stringify(log) + marknext
        + markname + "ds_q" + markeq + ds_q + marknext
        + markname + "ds_src" + markeq + ds_src + marknext
        + markname + "ds_rating" + markeq + ds_rating + marknext
        + markname + "ds_rt" + markeq + ds_rt + marknext
        + markname + "dp_q" + markeq + dp_q + marknext
        + markname + "dp_rating" + markeq + dp_rating + marknext
        + markname + "dp_rt" + markeq + dp_rt + marknext
        + markend;
    $.ajax({
        type: "POST",
        url: "https://experiments.affectivebrain.com/EL/f_submitdata_CIS.php", // This is a separate file that gets uploaded too
        data: { 'data': postdata}
    });

    $(".wrap_DebriefQ")
        .css({'font-size':'15pt', 'position':'fixed', 'top':'85%', 'left':'30%'})
        .show();
    // Point to debrief
    $('.StartEnd_text').html("<b>Well done! You have almost finished the experiment. </b> <br><br>" +
        "<p style='font-size: 0.8em'> Please complete the debriefing questionnaire using the link below. " +
        "When asked for your MTurk ID in the debrief questionnaire, please enter the ID: <br><br>" +
        query.worker_id + "</p> " +
        "<b>Please email the text strings to us at learnreward@gmail.com, with your MTurk ID in the subject line</b><br>" +
        "<p style='font-size: 0.8em'> In the previous sessions, we gave you a string of text to save. We would like you" +
        " to send all the text strings (2 from previous sessions, and the one shown below) to us at learnreward@gmail.com. <br><br>"+
        "The reason for doing this is because, some people have tried to do our experiment, but their computer has not been able " +
        "to send their data to us (often due to technical difficulties like their internet connection temporarily cutting off). " +
        "Emailing us your data in this way will help us make sure that we can pay you the full amount for the HIT that you have completed.</p><br>" +
        "<b> Please make sure you copy the text string below before submitting the Debrief completion code</b><br><br>" +
        "<p style='font-size: 0.8em'>Please make sure you copy the entire string of text - you might have to zoom out on your browser to see the whole text. " +
        "After you have finished the debrief questionnaire, enter the debrief completion code in the box below to get the " +
        "completion code for Amazon Turk</p><br> " +
        "[ START OF TEXT STRING ] <p style='font-size: 0.2em'> " + postdata + "</p> [ END OF TEXT STRING ]")
        .css({'top': '5%', 'font-size': '15pt'}).show();
    $("a[class='LinkDebrief']").attr('href', log.debrief_link).show();
}
function checkDebriefResp() {
    var fields = $(":input").serializeArray();
    if (fields[0].value == 'cis_dok') {   // Pointer back to MTurk
        $('.wrap_DebriefQ').hide();
        $('.StartEnd_text').html("You are now finished with the experiment<br><br>" +
            "Please copy the following completion code to MTurk: <br><br>" +  log.job.completecode  + "<br><br>" +
             "Thank you and have a great day!").show();
    }
    else {
        $('.StartEnd_text').html("Submitted code is incorrect!<br><br>" +
            "Please complete the debrief questionnaire and enter the debrief completion code in the box below!<br><br>")
            .show();
    }
}

// [3] Experiment execution ########################################
var goTrial= function() {
    $(document).on('keydown.start1', function (event) {  // Keypress to start
        if (event.keyCode==48) { // Press zero key to start
            $(document).off('keydown.start1');

            // Alter settings that applied for Instruction screen
            log.job.timestamp.start = new Date();
            $('.StartEnd_text').html(' ').hide();
            presRateSrc();
        }
    });
};
$(document).ready(goTrial); // Start the mother
