/**
 * Acquisition script for CIS: Session 3 (Choose)
 */

// [1] Set up session  ########################################
var DeveloperMode=0,            // Am I debugging?
    DeveloperAutoChoice=1,     // Automatically generate choices
    DeveloperSpeedUp =1,
    DeveloperMsg=1;
{
    //if (DeveloperMode==1) { console.log('URL pars manually added '); var urladd='?worker_id=HC_wid&assignment_aid=HC_aid&hit_id=HC_hid&srcstim=%22[%27bird%27,%27cat%27,%27elephant%27,%27fish%27]%22&chostim=[198,238,188,101,75,90,175,135,111,243,223,160,347,157,43,94,165,325,18,248,92,317,49,315,184,262,343,368,179,363,70,380,110,250,117,142,215,180,282,333,264,7,362,247,38,367,136,162,109,265,146,373,318,321,27,26,174,263,76,161,74,308,183,277,316,320,83,53,268,193,1,189,104,67,133,195,306,345,310,237,382,249,299,80,95,307,14,361,312,155,17,73,287,122,370,131,197,129,61,383,158,313,99,30,230,242,6,348,274,15,296,314,301,51,176,54,365,107,240,163,79,185,31,323,241,96,113,275,164,187,252,236,52,66,159,364,50,272,360,12,102,289,227,352,309,2,20,298,141,196,137,124,123,245,10,194,251,330,172,270,324,192,148,145,210,204,3,23,288,334,19,244,77,226,286,46,278,84,48,60,273,8,213,150,40,206,59,234,36,91,138,311,280,116,106,130,328,121,369,216,154,225,211,253,21,350,304,114,132,63,326,167,259,327,266,78,221,89,233,340,58,126,64]&srcstim=[%22fish%22,%22elephant%22,%22cat%22,%22bird%22]';  window.history.pushState({'page_id': 1, 'user_id': 5}, 'blah', 'h3_Choose.html' + urladd); }
    var query = opGetQueryParams(document.location.search);
} // Inputs for script running during setup

// [2] Set up Choice session // ###########################################
{
    // Design settings ////////////////////////////////////////////////
    if (DeveloperMode == 0) { DeveloperAutoChoice = 0; DeveloperMsg = 0; DeveloperSpeedUp = 0; }
    log.ntrials_infopair = 20;  // WARNING: If you are changing n trials, check if there's enough stim to go round w Learning stage
    log.ntrials_catch = 20;
    log.ntrials = log.ntrials_infopair*6+log.ntrials_catch;
    log.ntr_randbatch=100;       // [ NOT USED , SOMETHING WRONG ] Batch size (per src) for random num gen. Changing this changes the effectively randomness

    // // Fake n trials (debug) ---------------
    //log.ntrials_catch = 0;  console.log('WARNING: fake n catch trials')

    // Stimuli
    log.chostimset = shuffle(JSON.parse(query.chostim));
    if (log.chostimset.length < log.ntrials) { console.log('WARNING: Not enough stimuli for this no. trials!')}   // Obvs this check only works if you're working w the real n stim from learning stage
    log.srcstim = JSON.parse(query.srcstim);

    // Timing
    if (DeveloperSpeedUp) {
        log.Stim.time =1;
        log.time = {
            Fixation: 1,
            Ask: 1,
            AfterAsk: 1,
            ChooseSrc: 1,
            AfterChooseSrc: 1,
            InfoEvent: 1,
            OutcomeEvent: 1
        };
    } else {
        log.time = {
            Fixation: 1500,
            Ask: 15000,         // 15s as a stand in for infinite
            AfterAsk: 1000,     // After free timed choice
            ChooseSrc: 15000,             // 15s as a stand in for infinite
            AfterChooseSrc: 1000,          // After free timed src-choice
            InfoEvent: 2000,
            OutcomeEvent: 2000
        };
    }

    // Catch items
    log.catch_qs =[ // True/false questions
        'Your final guess was that the object IS a blap',              // Subject guess
        'Your final guess was that the object IS NOT a blap',
        'The other player guessed that the object IS a blap',            // Info/Source said
        'The other player guessed that the object IS NOT a blap',
        'The other player that you just heard from was the ' + log.srcstim[0].toUpperCase(),        // Which source
        'The other player that you just heard from was the ' + log.srcstim[1].toUpperCase(),
        'The other player that you just heard from was the ' + log.srcstim[2].toUpperCase(),
        'The other player that you just heard from was the ' + log.srcstim[3].toUpperCase(),

    ];
    log.catch_nq =  log.catch_qs.length/2; // Each subject gets asked half the Qs

    // Others
    log.key.options =  ['No', 'Yes'];
    log.key.source1 = log.key.left;
    log.key.source2 =  log.key.right;
    log.key.sourceoptions=  ['Left', 'Right']
    log.job = {
        hit_id: query.hit_id,
        worker_id: query.worker_id,
        assignment_id: query.assignment_id,
        Session: 'Choice',
        //URL_pars: query,
        DeveloperMode: DeveloperMode,
        timestamp: {}
    };
} // Design settings
{
    // Setup trial events  // ##########################################
    log.srcpair_src = [[1,2], [1,3], [1,4], [2,3], [2,4],[3,4], [0,0]];  // 7 is temporarily catch trials
    var d_stim1 =  opIndexReadVec(log.chostimset, opLinFromTo(0, log.ntrials-1,1)),
        d_srcpair =  shuffle(opVecRepmat([1,2,3,4,5,6], log.ntrials_infopair).concat(opVecRepmat(7, log.ntrials_catch))),
        d_src1 =  d_srcpair.map(s => log.srcpair_src[s-1][0]),  // MATE. Look at it. FUCKING LOOK AT IT. One line motherfucker.
        d_src2 =  d_srcpair.map(s => log.srcpair_src[s-1][1]),
        d_choice1 = new Array(log.ntrials).fill(999),  // First choice
        d_rt1  = new Array(log.ntrials).fill(0),
        d_chosrc = new Array(log.ntrials).fill(999),   // Chosen Source: 1=C, 2=D, 3=N,4=I
        d_chosrcRT = new Array(log.ntrials).fill(999),
        d_choice2 = new Array(log.ntrials).fill(999),  // Second choice
        d_rt2  = new Array(log.ntrials).fill(0),
        d_info  = new Array(log.ntrials).fill(999),
        d_randx= new Array(log.ntrials).fill(999),
        d_srcagree = new Array(log.ntrials).fill(999),
        dc_choice= new Array(log.catch_nq).fill(999),     // Catch question items
        dc_q = opIndexReadVec(shuffle(opLinFromTo(1, log.catch_qs.length,1)), opLinFromTo(0,log.catch_nq-1,1)),  // Sample requested subset of Qs
        dc_trial =opIndexReadVec(shuffle(opLinFromTo(2,log.ntrials-3,1)), opLinFromTo(0,log.catch_nq-1,1)).sort(function(a, b){return a-b}),
        randbins =[],
        trand = new Array(5).fill(0);  // [ NOT USED , SOMETHING WRONG ]

    // Random number bins for each source [ NOT USED , SOMETHING WRONG ]
    randbins[1] = shuffle( shuffle( shuffle( shuffle( shuffle( shuffle( opVecRepmat(opLinspace(0,1, log.ntr_randbatch),Math.ceil(3*log.ntrials_infopair/log.ntr_randbatch)) ))))));
    randbins[2] = shuffle( shuffle( shuffle( shuffle( shuffle( shuffle( opVecRepmat(opLinspace(0,1, log.ntr_randbatch),Math.ceil(3*log.ntrials_infopair/log.ntr_randbatch)) ))))));
    randbins[3] = shuffle( shuffle( shuffle( shuffle( shuffle( shuffle( opVecRepmat(opLinspace(0,1, log.ntr_randbatch),Math.ceil(3*log.ntrials_infopair/log.ntr_randbatch)) ))))));
    randbins[4] = shuffle( shuffle( shuffle( shuffle( shuffle( shuffle( opVecRepmat(opLinspace(0,1, log.ntr_randbatch),Math.ceil(3*log.ntrials_infopair/log.ntr_randbatch)) ))))));
    //pr('[ START ] Mean of all random numbers ----------- ')
    //pr('C: ' + opMean(randbins[1]).toFixed(3));
    //pr('D: ' + opMean(randbins[2]).toFixed(3));
    //pr('N: ' + opMean(randbins[3]).toFixed(3));
    //pr('I: ' + opMean(randbins[4]).toFixed(3));

    // FAKE
    //if (DeveloperMode==1) {dc_trial=[1,2,3,4];    pr('FAKE dc trials') }

    // Working variables
    for (var i= 0; i< dc_trial.length; i++ ) {  // Catch questions should not on the same trials as breaks
        if ( dc_trial[i] == (log.ntrials/3) || dc_trial[i] == Math.round(log.ntrials*(2/3))) { dc_trial[i]--;}
    }
    var wt=[],
        w=[],
        tn = 0,
        cn=0;
} // Trialstats settings
{
    pr('    Any bad random nums? -1 = none');  pr(d_randx.map(s => s== undefined).indexOf(true))
    var chowhich =[1,2,3,4], tt=1;                  // Equal choice
    //var chowhich =[1,1,1,1,1,2,2,2,3,3,4], tt=1;    // C > D > N > I
    //var chowhich =[1,1,1,1,1,2,3,3,3,4], tt=1;      // C > N > D > I


} // Options for simulating choices


// [3] Event functions ########################################
function presFixation(){
    $(".AskAns").hide();
    $('.StimMask').hide()
    $(".choicebinarytext").text(' ').hide()
    $('.StimQuestion').css({'font-size': '0.8em'}).hide()
    $('.Ask1').show()
    $('.Fixation').show()

    // Set up trial
    $('.StimPres').html('<img src="Stim/Shape/stim' + String(d_stim1[tn]) + '.bmp">').hide();
    if (d_src1[tn]>0) {
        if (Math.random() < 0.5) {
            wt.st =  d_src1[tn];
            d_src1[tn] = d_src2[tn];
            d_src2[tn] = wt.st;
        }  // Shuffle L/R of source presentation
        wt.pic1_name = log.srcstim[d_src1[tn]-1];
        wt.pic2_name = log.srcstim[d_src2[tn]-1];
        console.log( '[' + tn.toString() + '] Srcs ' +  String(d_src1[tn]) + ' & ' +  String(d_src2[tn]) + '  ('   + wt.pic1_name + ' & ' + wt.pic2_name +  ')');
        $('.ChooseInfo1').html('<img src="Stim/src_' + log.srcstim[d_src1[tn]-1] + '.png" height="' + String(log.Src.size) + 'px" width="' + String(log.Src.size) + 'px" alt =' + wt.pic1_name + ' >').hide();
        $('.ChooseInfo2').html('<img src="Stim/src_' + log.srcstim[d_src2[tn]-1] + '.png" height="' + String(log.Src.size) + 'px" width="' + String(log.Src.size) + 'px" alt =' + wt.pic2_name + ' >').hide();
    }

    // Display
    presTrialStatsPrint(1);
    if (DeveloperMode==1) {   // Press any key to continue. Comment out for testing
        //$(document).on('keydown.continue', function (event) {
        //    $(document).off('keydown.continue');
        //
        //    // Copied from below ###########
        //    setTimeout(function () {
        //        $('.Fixation').hide()
        //        presStim()
        //    }, log.time.Fixation);
        //})
        // Automatic progression - Copied from below ###########
        setTimeout(function () {
            $('.Fixation').hide()
            presStim()
        }, log.time.Fixation);
    }
    else {
        setTimeout(function() {
            $('.Fixation').hide()
            presStim()
        }, log.time.Fixation);
    }
}
function presStim(){
    $('.StimQuestion').show()
    $('.StimPres').show()
    wt.stim_start = new Date();

    setTimeout(function() {
        presAsk1()
    }, log.time.EvalEvent);
}
function presAsk1() {
    $('.Ask1').show();
    wt.ask1_start = new Date();

    if (DeveloperAutoChoice==1) {
        if (DeveloperSpeedUp) { wt.waifakekey =1} else {wt.waifakekey =2000}
        d_choice1[tn] = Math.round(Math.random());   // Random binary choice
        d_rt1[tn] = 600 + tn;

        setTimeout(function () {
            $('.AskAns').text(opFmat(['No', 'Yes'], d_choice1[tn]))
                .css({'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                .show();
        },900);

        //   COPIED FROM BELOW ---
        setTimeout(function () {
            $('.Ask1').hide();
            $('.StimQuestion').hide();
            presAskConfidence(1)
        }, wt.waifakekey);  // Continue with trials
    }
    else {
        $(document).on('keydown.ask1', function (event) {
            wt.ask1_keydown = new Date();
            switch (event.keyCode) {
                case log.key.yes:
                    d_choice1[tn]=1;
                    break;
                case log.key.no:
                    d_choice1[tn]=0;
                    break;
            }
            if (d_choice1[tn] > -0.5 && d_choice1[tn] < 1.5) {  // If response is OK
                $(document).off('keydown.ask1');
                d_rt1[tn] = opGetRT(wt.ask1_start, wt.ask1_keydown);
                $('.AskAns').text(opFmat(['No','Yes'], d_choice1[tn]))
                    .css({'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                    .show();

                setTimeout(function () {
                    $('.Ask1').hide();
                    $('.StimQuestion').hide();
                    presAskConfidence(1)
                }, log.time.AfterAsk);  // Continue with trials
            }
        })
    }
}
function presAskConfidence(qnum) {
    //$('.AskConfidence').show(); // Confidence is skipped - just using the workflow code here

    if (DeveloperAutoChoice==1) {
        setTimeout(function () {
            wt.confidence = Math.ceil(Math.random()*3);

            // COPIED FROM BELOW
            if (wt.confidence > 0.5 && wt.confidence < 3.5) {
                setTimeout(function () {
                    $('.AskConfidence').hide();
                    if (d_srcpair[tn] > 0.5 && d_srcpair[tn] < 6.5) { // Info trial
                        switch (qnum) {
                            case 1:
                                //d_confidence1[tn]= wt.confidence;
                                presChooseSource();
                                break
                            case 2:
                                //d_confidence2[tn]= wt.confidence;
                                presTrialStatsPrint(2);
                                opEndTrial();
                                break
                        }
                    } else { // Catch trial (easy)
                        opEndTrial();
                    }

                }, log.time.AskEvalEvent);
            }

        }, 0);
    }
    else {
        //$(document).on('keydown.askconfidence', function (event) {
        //    switch (event.keyCode) {
        //        case log.key.k1:
        //            wt.confidence  = 1;
        //            break;
        //        case log.key.k2:
        //            wt.confidence  = 2;
        //            break;
        //        case log.key.k3:
        //            wt.confidence  = 3;
        //            break;
        //        default:
        //            wt.confidence = 0;
        //    }
        wt.confidence=1;
        if (wt.confidence > 0.5 && wt.confidence < 3.5) {
                //$(document).off('keydown.askconfidence');

                setTimeout(function () {
                    $('.AskConfidence').hide();
                    if (d_srcpair[tn] > 0.5 && d_srcpair[tn] < 6.5) { // Info trial
                        switch (qnum) {
                            case 1:
                                //d_confidence1[tn]= wt.confidence;
                                presChooseSource();
                                break;
                            case 2:
                                //d_confidence2[tn]= wt.confidence;
                                presTrialStatsPrint(2);
                                opEndTrial();
                                break;
                        }
                    } else { // Catch trial (easy)
                        opEndTrial();
                    }
                }, log.time.AfterAsk);
            }
        //})
    }
}
function presChooseSource(){
    $(".StimPres").hide();
    $('.AskAns').hide();
    $(".ChooseInfo1").show();
    $(".ChooseInfo2").show();
    $(".ChooseInfoText").css({'font-size': '0.8em'}).show()
    $(".wrap_ChooseInfo").show()
    wt.source_start = new Date();

    if (DeveloperAutoChoice==1) {

        if (DeveloperSpeedUp) { wt.waifakekey =1} else {wt.waifakekey =1200}
        setTimeout(function () {
        // Choose with specific probabilities, IGNORING what's on screen
        //d_chosrc[tn] = chowhich[tt - 1];
        //if (tt == chowhich.length) { tt = 1 } else { tt++ }
        //wt.chosourceLR=Math.round(Math.random()*1)+1;

        // Choose at random from available options
        wt.chosourceLR=Math.round(Math.random())+1;
        d_chosrc[tn] = opFmat([d_src1[tn],d_src2[tn]],wt.chosourceLR-1);


        //   COPIED FROM BELOW ---
        if (d_chosrc[tn]> 0.5 && d_chosrc[tn] < 4.5) {  // If response is OK
            setTimeout(function () {
                presInfo(wt.chosourceLR)
            }, log.time.AfterChooseSrc);
        }

        }, wt.waifakekey);
        }
    else {
        $(document).on('keydown.choosesource', function (event) {
            wt.ask_keydown = new Date();
            switch (event.keyCode) {
                case log.key.source1:  // Left = 1, Right = 2
                    d_chosrc[tn] =  d_src1[tn];
                    wt.chosourceLR=1;
                    break;
                case log.key.source2:
                    d_chosrc[tn] = d_src2[tn];
                    wt.chosourceLR=2;
                    break;
                default:
                    d_chosrc[tn] = 0;
            }
            if (d_chosrc[tn]> 0.5 && d_chosrc[tn] < 4.5) {  // If response is OK
                $(document).off('keydown.choosesource');   // Turn off further key collection
                d_chosrcRT[tn] = opGetRT(wt.source_start, wt.ask_keydown);

                setTimeout(function () {
                    presInfo(wt.chosourceLR)
                }, log.time.AfterChooseSrc);
            }
        });
    }
}
function presInfo(infosourceLR){



    // Knock on properties - fix agreeableness [ SOMETHING WRONG W THIS ]
    //d_randx[tn] = randbins[d_chosrc[tn]][trand[d_chosrc[tn]-1]];  // Allocate random number
    //if (trand[d_chosrc[tn]] == randbins[d_chosrc[tn]].length-1) { trand[d_chosrc[tn]] ==0 } else { trand[d_chosrc[tn]]++ }

    // Purely random numbers
    d_randx[tn] = Math.random();

    wt.pAgree = 0.5 + (log.pCorrect[log.Src.condition[d_chosrc[tn]-1]][1] - log.pCorrect[log.Src.condition[d_chosrc[tn]-1]][0])/2;
    if (d_randx[tn] <= wt.pAgree) {
        d_info[tn]= d_choice1[tn];
    }  else {
        d_info[tn]= Math.abs(1-d_choice1[tn]);
    }
    d_srcagree[tn]= +(d_info[tn]==d_choice1[tn]);


    console.log('   SrcPair ' + String(d_srcpair[tn]) + '   Info ' + opFmat(['No', 'Yes'], d_info[tn]))

    switch (infosourceLR) {
        case 1:         // Left source (#1)
            $(".ChooseInfo2").hide();
            setTimeout(function() {
                $(".Info").css({'left': $(".ChooseInfo1").css('left')}).text(opFmat(['No', 'Yes'], d_info[tn])).show();
            }, Math.round(log.time.InfoEvent/4));
            break;
        case 2:         // Right source (#1)
            $(".ChooseInfo1").hide();
            setTimeout(function() {
                $(".Info").css({'left': $(".ChooseInfo2").css('left')}).text(opFmat(['No', 'Yes'], d_info[tn])).show();
            }, Math.round(log.time.InfoEvent/4));
            break;
    }
    setTimeout(function() {
        $(".ChooseInfo1").hide();
        $(".ChooseInfo2").hide();
        $(".Info").hide();
        $(".ChooseInfoText").hide();
        presAsk2()
    }, log.time.InfoEvent);
}
function presAsk2() {
    $('.Ask1').show();
    $('.Ask2').show();
    wt.ask2_start= new Date();

    if (DeveloperAutoChoice==1) {
        if (DeveloperSpeedUp) { wt.waifakekey =1} else {wt.waifakekey =1500}
        setTimeout(function () {

            // Follow advice given by info source
            //d_choice2[tn] = d_info[tn];

            // Second choice is random
            d_choice2[tn] = opFmat([d_info[tn], 1-d_info[tn]], Math.round(Math.random()));

            // COPIED FROM BELOW ########################################################
            d_rt2[tn] = 600+tn;
            $('.AskAns').text(opFmat(['No','Yes'], d_choice2[tn]))
                .css({'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                .show();

            setTimeout(function () {
                $(".Ask1").hide();
                $(".Ask2").hide();
                $(".AskAns").hide();
                presAskConfidence(2)
            }, log.time.AfterAsk);
        }, wt.waifakekey);
    }
    else {
        $(document).on('keydown.ask2', function (event) {
            wt.ask_keydown = new Date();
            switch (event.keyCode) {
                case log.key.yes:
                    d_choice2[tn] = 1;
                    break;
                case log.key.no:
                    d_choice2[tn] = 0;
                    break;
                default:
                    d_choice2[tn] = 999;
                    d_rt2[tn] = 999;
            }
            if (d_choice2[tn] > -0.5 && d_choice2[tn] < 1.5) {  // If response is OK
                $(document).off('keydown.ask2');

                // Process the recorded response
                d_rt2[tn] = opGetRT(wt.ask2_start, wt.ask_keydown);
                $('.AskAns').text(opFmat(['No','Yes'], d_choice2[tn]))
                    .css({'position': 'fixed', 'top': '80%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
                    .show();
                setTimeout(function () {
                    $(".Ask1").hide();
                    $(".Ask2").hide();
                    $(".AskAns").hide();
                    presAskConfidence(2)
                }, log.time.AfterAsk);
            }
        });
    }

}
function presCatchQ() {
    $('.AskAns').hide()
    $(".Catch").html("Is the statement below (about the trial you just completed) true or false?<br><br><br><br><br><br>" +
            '<b>' + log.catch_qs[dc_q[cn]-1] + '</b><br><br><br><br><br><br>' +
            "Press the UP arrow for TRUE, and the DOWN arrow for FALSE")
        .css({'font-size': '0.8em'})
        .show();

    if (DeveloperAutoChoice==1) {
        if (DeveloperSpeedUp) { wt.waifakekey =2} else {wt.waifakekey =4700}
        setTimeout(function () {
            dc_choice[cn]= Math.round(Math.random());
            pr('Catch no ' + cn + ' response:  ' + dc_choice[cn])
            cn++;
            tn++;

            // Continue with trials
            $(".Catch").hide();
            presFixation();
        }, wt.waifakekey);
    }
    else {
        $(document).on('keydown.askcatch', function (event) {
            wt.askcatch= new Date();
            switch (event.keyCode) {
                case log.key.yes:
                    dc_choice[cn]=1;
                    break;
                case log.key.no:
                    dc_choice[cn]=0;
                    break;
            }
            pr('Catch no ' + cn + ' response:  ' + dc_choice[cn])
            if (dc_choice[cn]> -0.5 && dc_choice[cn]< 1.5) {  // If response is OK
                $(document).off('keydown.askcatch');
                cn++;
                tn++;

                // Continue with trials
                setTimeout(function () {
                    $(".Catch").hide();
                    presFixation();
                }, log.time.AfterAsk);
            }
        })
    }
}
function presTrialStatsPrint(which) {    //  Print to display, end trial
    // Input: 1=Start, 2=End
    if (DeveloperMsg== 1) {
        switch (which) {
            case 1: // Start
                $(".DevMsgStart").html("[Trial " + tn.toString() + "] Sources: " + log.srcstim[d_src1[tn]-1] + ' vs ' + log.srcstim[d_src2[tn]-1] +  '    (' + log.Src.condition[d_src1[tn]-1] + ' vs ' + log.Src.condition[d_src2[tn]-1] + ')').show();
                break;
            case 2:  // End
                $(".DevMsgEnd").html("[Trial " + tn.toString() + "] Sources: " + log.srcstim[d_src1[tn]-1] + ' vs ' + log.srcstim[d_src2[tn]-1] +  '    (' + log.Src.condition[d_src1[tn]-1] + ' vs ' + log.Src.condition[d_src2[tn]-1] + ') <br><br>' +
                "Chosen source: " + log.srcstim[d_chosrc[tn]-1] + '   says  ' + opFmat(['No', 'Yes'], d_info[tn]) + '  (' + opFmat(['Disagree', 'Agree'], d_srcagree[tn]) + ')<br><br>' +
                "Subj choices: " + opFmat(['No', 'Yes'], d_choice1[tn]) + ', ' +  opFmat(['No', 'Yes'], d_choice2[tn])).show();
                break;
        }
    }
}
function presBreakScreen() {
    if ( tn <Math.round(log.ntrials*(2/3)) ) {
        wt.breakmsg="You are currently 1/3 of the way through this session";
    }
    else {
        wt.breakmsg="You are currently 2/3 of the way through this session";
    }
    $('.StartEnd_text').html("Please take a break if you'd like<br><br>"
        + wt.breakmsg
        + "<br><br>Press any key to continue with the experiment").show();
    $('.wrap_ChoiceTrial').hide()


    // Fake: Waiting for other players to catch up
    wt.fakewait =  +(Math.random()<0.5)*(5+ Math.random()*6)*1000;



    if (DeveloperAutoChoice == 1) {
        if (wt.fakewait>0) {
            $('.StartEnd_text').html('Please wait a few seconds for the other players to catch up<br>' +
                'Estimated wait: No more than 20 seconds');
        }
        setTimeout(function () {    // Fake waiting (for other player to catch up
            setTimeout(function () {
                $('.StartEnd_text').html(' ');
                $('.wrap_ChoiceTrial').show();

                presFixation()
            }, 1000);  // Continue after 1s
        },wt.fakewait);
    }
    else {
        $(document).on('keydown.break', function (event) {
            $(document).off('keydown.break');
            if (wt.fakewait>0) {
                $('.StartEnd_text').html('Please wait a few seconds for the other players to catch up<br>' +
                    'Estimated wait: No more than 20 seconds');
                $('.SourceStim').hide()
            }
            setTimeout(function () {    // Fake waiting (for other player to catch up
                setTimeout(function () {
                    $('.StartEnd_text').html(' ');
                    $('.wrap_ChoiceTrial').show();
                    presFixation()
                }, 1000);  // Continue after 1s
            },wt.fakewait);
        })
    }

}
function opEndTrial(){ 
    $('.Ask1').hide();
    $('.Ask2').hide();
    $('.ChooseInfo1').hide();
    $('.ChooseInfo2').hide();
    //$('.Choosechoicebinarytext').hide();
    $('.StimPres').hide();
    $('.StimMask').hide();

    if (tn == log.ntrials-1) {
        $('.Fixation').hide();
        $('.LinkInstruc').show();
        $('.wrap_ChoiceTrial').hide();
        opPostData();
    }
    else if (tn+1 == dc_trial[cn]) {
        presCatchQ()
    }
    else if (tn == Math.round(log.ntrials/3)  || tn == Math.round(log.ntrials*(2/3)))  {  // If you change when breaks are triggered, make sure that catch Qs are not triggered on the same trial
        tn++;
        presBreakScreen()
    }
    else { // Any changes here should be copied to presCatchQ
        tn++;
        presFixation()
    }
}
function opPostData(){
    log.job.timestamp.end = new Date();
    console.log("TIME TAKEN:  " + String( log.job.timestamp.end.getHours()-log.job.timestamp.start.getHours()) + " hrs " + String(log.job.timestamp.end.getMinutes()- log.job.timestamp.start.getMinutes()) + " minutes")
    //pr('ENDING w bad rands?'); pr(d_randx.map(s => s== undefined).indexOf(true));

    if (DeveloperMsg!=1) { $('.DevMsgStart').html(log.job.timestamp.start + '<br>'+  log.job.timestamp.end).show(); }


    pr('[ END ] Mean of all random numbers ----------- ');
    pr('C: ' + opMean(randbins[1]).toFixed(3));
    pr('D: ' + opMean(randbins[2]).toFixed(3));
    pr('N: ' + opMean(randbins[3]).toFixed(3));
    pr('I: ' + opMean(randbins[4]).toFixed(3));

    pr('[ END ] Mean randx for each src ----------- ');
    for (var sr= 1; sr< 5; sr++) {
        pr(log.Src.condition[sr-1] + ': ' + opMean(opIndexReadVec(d_randx,opNumFindInd(d_chosrc, sr))).toFixed(3) + '      counter = ' + trand[sr])
    }
    pr('[ END ] pAgree  ----------- ');
    for (var sr= 1; sr< 5; sr++) {
        pr(log.Src.condition[sr-1] + ': ' + opMean(opIndexReadVec(d_randx,opNumFindInd(d_chosrc, sr))).toFixed(3))
    }
    pr('[ END ] pCho  ----------- ');
    for (var sr= 1; sr< 5; sr++) {
        pr(log.Src.condition[sr-1] + ': ' + (opNumFindInd(d_chosrc, sr).length/(opNumFindInd(d_src1, sr).length + opNumFindInd(d_src2, sr).length)).toFixed(3) + '    = ' + opNumFindInd(d_chosrc, sr).length + ' out of ' + (opNumFindInd(d_src1, sr).length + opNumFindInd(d_src2, sr).length) + ' opportunities' )
    }



    // Post to Server
    var postdata= markname + "subject" + markeq + log.job.worker_id + marknext
        + markname + "session" + markeq + "2Choice" + marknext
        + markname + "log" + markeq + JSON.stringify(log) + marknext
        + markname + "d_stim1" + markeq + d_stim1 + marknext
        + markname + "d_src1" + markeq + d_src1 + marknext
        + markname + "d_src2" + markeq + d_src2 + marknext
        + markname + "d_info" + markeq + d_info + marknext
        + markname + "d_choice1" + markeq + d_choice1 + marknext
        + markname + "d_choice2" + markeq + d_choice2 + marknext
        + markname + "d_rt1" + markeq + d_rt1+ marknext
        + markname + "d_rt2" + markeq + d_rt2+ marknext
        + markname + "d_chosrc" + markeq + d_chosrc + marknext
        + markname + "d_chosrcRT" + markeq + d_chosrcRT + marknext
        + markname + "dc_choice" + markeq + dc_choice + marknext
        + markname + "dc_q" + markeq + dc_q + marknext
        + markname + "dc_trial" + markeq + dc_trial + marknext
        + markname + "d_randx" + markeq + d_randx + marknext
        + markend;
    $.ajax({
        type: "POST",
        url: "https://experiments.affectivebrain.com/EL/f_submitdata_CIS.php",
        data: { 'data': postdata}
    });

    // Display
    $('.StartEnd_text').html("<b>You are finished with this stage of the experiment!</b><br> Please feel free to take a break <br><br>" +
            "Please save the text string below (e.g. by copying it into a blank document on your computer). You will need to provide " +
            "it later on.  <br><br>If you find that you are unable to complete the experiment for whatever reason, please email the text string " +
            "to learnreward@gmail.com, with your MTurk ID in the subject line. <br><br>" +
            "Make sure you save the entire string of text - you might have to zoom out on your browser to see the whole text.<br><br><br><br>" +
            "<b>When you are ready to continue, click on the link below to continue with the next session's instructions</b><br><br><br>"+
            "[ START OF TEXT STRING ] <p style='font-size: 0.3em'> " + postdata + "</p> [ END OF TEXT STRING ] </p>")
        .css({ 'width': '800px', 'position': 'fixed', 'top': '40%', 'left': '50%', 'transform': 'translate(-50%, -50%)'})
        .show()

    // Post to next session
    var nextlink='h4_Rate.html?'  // Append details to be passed to next session
        + "worker_id=" + log.job.worker_id + "&assignment_id=" + log.job.assignment_id + "&hit_id=" + log.job.hit_id
        + "&srcstim=" +  JSON.stringify(log.srcstim);
    $("a[class='LinkInstruc']").attr('href', nextlink);

    if (DeveloperMsg) {
        $('.DevMsgEnd').html(
            'Done<br><br>' +
            postdata
        ).show()
    }
}

// [4] Experiment execution ########################################
var goTrial= function() {

    // Record details
    log.job.timestamp.start =  new Date();
    $('.StimQuestion').text(log.Stim.q).hide();

    if (DeveloperMsg!=1) {
        $('.DevMsgStart').hide()
        $('.DevMsgEnd').hide()
        }
    setTimeout(function() {
        $('.StartEnd_text').css({'font-size': '0.8em'}).hide()
        presFixation();
    }, 2000);
}
$(document).ready(goTrial);