({
	calculateOverallProf4Params: function(a, b, c, d) {
    var oveProfVal = 0;
    var profLvlSum = 0;
    var profLvlCnt = 0;

    if ((a || b || c || d !== "") && (a || b || c || d !== undefined)) {
      var profLvlArr = [];
      profLvlArr.push(parseInt(a));
      profLvlArr.push(parseInt(b));
      profLvlArr.push(parseInt(c));
      profLvlArr.push(parseInt(d));

      for (var i in profLvlArr) {
      if (
        profLvlArr[i] !== 0 &&
        profLvlArr[i] !== 6 &&
        profLvlArr[i] !== undefined &&
        !isNaN(profLvlArr[i])
      ) {
        profLvlSum += profLvlArr[i];
        profLvlCnt++;
      }
    }
      oveProfVal = parseInt(profLvlSum) / parseInt(profLvlCnt);
      oveProfVal = oveProfVal.toFixed(2);
    }

    if (isNaN(oveProfVal)) {
      oveProfVal = "";
    }

    return oveProfVal;
  }
})