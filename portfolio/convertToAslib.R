library(aslib)
library(BBmisc)
library(plyr)
library(reshape2)

features.cheap = read.table("gpgnode-sip-cheap-features.data", header = TRUE, sep = " ", stringsAsFactors = FALSE)
features.cheap$family = NULL
names(features.cheap)[-1] = paste0("cheap.", names(features.cheap))[-1]
features.distance = read.table("gpgnode-sip-distance-features.data", header = TRUE, sep = " ", stringsAsFactors = FALSE)
features.distance$family = NULL
names(features.distance)[-1] = paste0("distance.", names(features.distance))[-1]
features.lad = read.table("gpgnode-sip-lad-features.data", header = TRUE, sep = " ", stringsAsFactors = FALSE)
features.lad$family = NULL

times = read.table("gpgnode-sip-runtimes.data", header = TRUE, sep = " ", stringsAsFactors = FALSE)
times$family = NULL
times$vbs = NULL
times$sat = NULL

timeout = 1e8/1000
algorithms = names(times)[-1]

feats.cheap.pattern = names(features.cheap)[grep("pattern.", names(features.cheap), fixed = TRUE)][-1]
costs.cheap.pattern = "cheap.pattern.time"
feats.cheap.target = names(features.cheap)[grep("target.", names(features.cheap), fixed = TRUE)][-1]
costs.cheap.target = "cheap.target.time"

feats.distance.pattern = names(features.distance)[grep("pattern.", names(features.distance), fixed = TRUE)][-1]
costs.distance.pattern = "distance.pattern.time"
feats.distance.target = names(features.distance)[grep("target.", names(features.distance), fixed = TRUE)][-1]
costs.distance.target = "distance.target.time"

feats.lad = names(features.lad)[grep("lad.", names(features.lad), fixed = TRUE)]
costs.lad = "lad.time"
presolved.lad = "lad.detected.inconsistent"
feats.lad = feats.lad[!(feats.lad %in% c(costs.lad, presolved.lad))]

# convert ms to s to avoid integer overflows later
for (alg in algorithms) {
    times[,alg] = times[,alg] / 1000
    times[,alg][times[,alg] >= timeout] = NA
}
features.cheap[,costs.cheap.pattern] = features.cheap[,costs.cheap.pattern] / 1000
features.cheap[,costs.cheap.target] = features.cheap[,costs.cheap.target] / 1000
features.distance[,costs.distance.pattern] = features.distance[,costs.distance.pattern] / 1000
features.distance[,costs.distance.target] = features.distance[,costs.distance.target] / 1000
features.lad[,costs.lad] = features.lad[,costs.lad] / 1000

# convert to aslib
desc = makeS3Obj("ASScenarioDesc",
  scenario_id = "graphs-2015",
  features_deterministic = c(feats.cheap.pattern, feats.cheap.target, feats.distance.pattern, feats.distance.target, feats.lad),
  features_stochastic = character(0),
  algorithms_deterministic = algorithms,
  algorithms_stochastic = character(0),

  performance_measures = "time",
  performance_type = "runtime",
  maximize = FALSE,

  algorithm_cutoff_time = timeout,
  algorithm_cutoff_memory = NA,
  features_cutoff_time = NA,
  features_cutoff_memory = NA,

  number_of_feature_steps = 5,
  default_steps = c("cheap_pattern", "cheap_target", "distance_pattern", "distance_target", "lad_features"),
  feature_steps =
      list(cheap_pattern = list(provides = feats.cheap.pattern),
           cheap_target = list(provides = feats.cheap.target),
           distance_pattern = list(provides = feats.distance.pattern),
           distance_target = list(provides = feats.distance.target),
           lad_features = list(provides = feats.lad))
)

mfeats = merge(merge(features.cheap, features.distance, by = "instance"), features.lad, by = "instance")

feature.values = cbind(instance_id = mfeats$instance, repetition = 1, mfeats[, c(feats.cheap.pattern, feats.cheap.target, feats.distance.pattern, feats.distance.target, feats.lad)])
feature.values$instance_id = as.character(feature.values$instance_id)

feature.runstatus = data.frame(instance_id = mfeats$instance, repetition = 1, cheap_pattern = "ok", cheap_target = "ok", distance_pattern = "ok", distance_target = "ok", lad_features = ifelse(mfeats[, presolved.lad] == "true", "presolved", "ok"))
feature.runstatus$instance_id = as.character(feature.runstatus$instance_id)
feature.runstatus$cheap_pattern = factor(feature.runstatus$cheap_pattern)
feature.runstatus$cheap_target = factor(feature.runstatus$cheap_target)
feature.runstatus$distance_pattern = factor(feature.runstatus$distance_pattern)
feature.runstatus$distance_target = factor(feature.runstatus$distance_target)
feature.runstatus$lad_features = factor(feature.runstatus$lad_features)

feature.costs = data.frame(instance_id = mfeats$instance, repetition = 1, cheap_pattern = mfeats[, costs.cheap.pattern], cheap_target = mfeats[, costs.cheap.target], distance_pattern = mfeats[, costs.distance.target], distance_target = mfeats[, costs.distance.target], lad_features = mfeats[, costs.lad])
feature.costs$instance_id = as.character(feature.costs$instance_id)

algo.runs = cbind(instance_id = times$instance, times[, -1])
algo.runs = melt(algo.runs, id.vars = "instance_id", value.name = "time", variable.name = "algorithm")
algo.runs$repetition = 1L
algo.runs$runstatus = factor(ifelse(is.na(algo.runs$time), "timeout", "ok"))
algo.runs$algorithm = as.character(algo.runs$algorithm)
algo.runs$instance_id = as.character(algo.runs$instance_id)

algo.runstatus = as.matrix(times[, -1])
algo.runstatus[is.na(algo.runstatus)] = "timeout"
algo.runstatus[!is.na(algo.runstatus)] = "ok"
algo.runstatus = cbind(instance_id = times$instance, as.data.frame(algo.runstatus))
algo.runstatus = melt(algo.runstatus, id.vars = "instance_id", value.name = "status")
algo.runstatus$repetition = 1L
algo.runstatus$instance_id = as.character(algo.runstatus$instance_id)

cv.splits = data.frame(instance_id = times$instance, repetition = 1L,
  fold = sample(rep(1:10, length.out = length(times$instance))))
cv.splits$instance_id = as.character(cv.splits$instance_id)

ast = makeS3Obj("ASScenario",
  desc = desc,
  feature.runstatus = feature.runstatus,
  feature.costs = feature.costs,
  feature.values = feature.values,
  algo.runs = algo.runs,
  algo.runstatus = algo.runstatus,
  cv.splits = cv.splits
)

unlink("graphs-2015", recursive = TRUE)
writeASScenario(ast, path = "graphs-2015")
